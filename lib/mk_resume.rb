require 'prawn'
require 'prawn/measurement_extensions'
require_relative 'preproc'

# 플레인 텍스트 형식으로 적은 이력서를 pdf로 변환하기 위한 스크립트

DOC_MARGIN = {:top => 2.cm, :right => 3.05.cm, :bottom => 2.cm, :left => 3.05.cm}
FONT_SIZE = {:name => 11, :channel => 10, :heading => 9.5, :body => 9.5}

def run(relative_path)
  link_style = "<color rgb='888888'><u>%s</u></color>"

  Prawn::Document.generate(
    "output.pdf",
    page_size: "A4",
    margin: [DOC_MARGIN[:top], DOC_MARGIN[:right], DOC_MARGIN[:bottom], DOC_MARGIN[:left]]
  ) do |doc|

    Prawn::Font::AFM.hide_m17n_warning = true
    doc.font_families.update(
      "NotoSans" => {
        normal: "./fonts/NotoSansKR-Regular.ttf",
        bold: "./fonts/NotoSansKR-Bold.ttf"
      }
    )
    doc.font "NotoSans"

    ["personal_info"].each do |heading|
      personal_info = File.readlines(File.join(File.dirname(__FILE__), *relative_path, *%W[personalInfo])).map(&:chomp)

      doc.text(
        personal_info[0],
        size: FONT_SIZE[:name],
        style: :bold,
        leading: 8
      )

      personal_info[1..2].each do |item|
        doc.text(
          item,
          size: FONT_SIZE[:channel],
          leading: 5,
        )
      end

      doc.text(
        link_style % personal_info[3],
        size: FONT_SIZE[:channel],
        leading: 5,
        inline_format: true
      )

      # blog 링크
      doc.text(
        link_style % personal_info[4],
        size: FONT_SIZE[:channel],
        leading: 5,
        inline_format: true
      )
    end

    doc.move_down 14.5

    [{level: 4, text: "Introduction"}].each do |heading|
      doc.stroke_horizontal_rule
      doc.move_down 9.5
      line_height = 1.45
      doc.text(
        heading[:text],
        size: FONT_SIZE[:heading],
        style: :bold,
        leading: line_height * FONT_SIZE[:heading]
      )
      intro_info = File.readlines(File.join(File.dirname(__FILE__), *relative_path, *%W[introduction])).map(&:chomp)

      intro_info.each do |item|
        doc.indent(doc.width_of("- ")) do
          doc.text(
            "- #{item}",
            size: FONT_SIZE[:body],
            leading: 6,
            indent_paragraphs: 0
          )
        end

        doc.move_down 2
      end
    end

    doc.move_down 14.5

    [{ level: 4, text: "Work Experience" }].each do |heading|
      doc.stroke_horizontal_rule
      doc.move_down 9.5
      line_height = 1.45
      doc.text(
        heading[:text],
        size: FONT_SIZE[:heading],
        style: :bold,
        leading: line_height * FONT_SIZE[:heading]
      )

      pp = Preproc.new
      work_info = []
      wis = pp.split_by_company(File.read(File.join(File.dirname(__FILE__), *relative_path, *%W[workExperience])))
      wis.each do |wi|
        work_info << pp.group_by_company(wi.join("\n"))
      end

      work_info.each.with_index do |wi, idx|
        doc.text(
          wi[:company_nm],
          size: FONT_SIZE[:body],
          leading: 6,
          indent_paragraphs: 0
        )
        doc.move_down 2
        doc.text(
          "사용기술: #{wi[:skill_set]}",
          size: FONT_SIZE[:body],
          leading: 12,
          indent_paragraphs: 0
        ) if wi[:skill_set]
        doc.move_down 2 if wi[:skill_set]

        wi[:project].keys.each do |solve|
          doc.text(
            solve,
            size: FONT_SIZE[:body],
            leading: 6,
            indent_paragraphs: 0
          )

          what_n_details_list = wi[:project][solve]
          what_n_details_list.each do |what_n_details|
            what_n_details.each_key {|what|
              doc.indent(doc.width_of("      ")) do
                doc.text(
                  what,
                  size: FONT_SIZE[:body],
                  leading: 6,
                  indent_paragraphs: 0
                )
              end if what != :EMPTY_WHAT
              details = what_n_details[what]
              details.each do |detail_item|
                doc.indent(doc.width_of("      ")) do
                  doc.text(
                    "- #{detail_item}",
                    size: FONT_SIZE[:body],
                    leading: 6,
                    indent_paragraphs: 0
                  )
                end
                doc.move_down 2
              end
              doc.move_down 2
              doc.move_down 2
              doc.move_down 2
            }
          end
        end
      end
    end

    doc.move_down 2
    doc.move_down 14.5

    [{ level: 4, text: "Side Project" }].each do |heading|
      doc.stroke_horizontal_rule
      doc.move_down 9.5
      line_height = 1.45
      doc.text(
        heading[:text],
        size: FONT_SIZE[:heading],
        style: :bold,
        leading: line_height * FONT_SIZE[:heading]
      )

      pp = Preproc.new
      side_project_info = []
      wis = pp.split_by_company(File.read(File.join(File.dirname(__FILE__), *relative_path, *%W[sideProject])))
      wis.each do |wi|
        side_project_info << pp.group_by_company(wi.join("\n"))
      end

      side_project_info.each do |spi|
        spi[:project].keys.each do |project|

          if project.match(/<link href='([^']*)'>([^<]*)<\/link>/)
            link_url = Regexp.last_match(1)
            link_text = Regexp.last_match(2)

            doc.formatted_text([
              { text: spi[:company_nm], size: FONT_SIZE[:body], leading: 6 },
              { text: " (", size: FONT_SIZE[:body] },
              { text: "#{link_text}", size: FONT_SIZE[:body], leading: 6, styles: [:underline], color: "888888", link: link_url },
              { text: ")", size: FONT_SIZE[:body] },
            ], indent_paragraphs: 0)
          else
            doc.formatted_text([
              { text: spi[:company_nm], size: FONT_SIZE[:body], leading: 6 },
              { text: " ", size: FONT_SIZE[:body] },
              { text: project, size: FONT_SIZE[:body], leading: 6 }
            ], indent_paragraphs: 0)
          end

          doc.move_down 2

          what_n_details_list = spi[:project][project]
          what_n_details_list.each do |what_n_details|
            what_n_details.each_key {|what|
              doc.indent(doc.width_of("      ")) do
                doc.text(
                  what,
                  size: FONT_SIZE[:body],
                  leading: 6,
                  indent_paragraphs: 0
                )
              end if what != :EMPTY_WHAT
              details = what_n_details[what]
              details.each do |detail_item|
                doc.indent(doc.width_of("      ")) do
                  doc.text(
                    "- #{detail_item}",
                    size: FONT_SIZE[:body],
                    leading: 6,
                    indent_paragraphs: 0
                  )
                end
                doc.move_down 2
              end
              doc.move_down 2
              doc.move_down 2
              doc.move_down 2
            }
          end
        end
      end
    end

    doc.move_down 2
    doc.move_down 14.5

    [{ level: 4, text: "Education" }].each do |heading|
      doc.stroke_horizontal_rule
      doc.move_down 9.5
      line_height = 1.45
      doc.text(
        heading[:text],
        size: FONT_SIZE[:heading],
        style: :bold,
        leading: line_height * FONT_SIZE[:heading]
      )

      education_info = File.readlines(File.join(File.dirname(__FILE__), *relative_path, *%W[education]))
                           .map! { |cols|
                             cols.split(",")
                                 .each { |col| col.strip! }
                           }

      left_col_width = 180 # Adjust based on content and page layout needs
      right_col_start = left_col_width + 10 # Spacing between columns
      education_info.each do |left_text, right_text|
        # Draw left column text
        doc.text_box(
          left_text,
          size: FONT_SIZE[:body],
          at: [0, doc.cursor],
          width: left_col_width,
          align: :left
        )

        # Draw right column text, positioned to start at the right_col_start
        doc.text_box(
          right_text,
          size: FONT_SIZE[:body],
          at: [right_col_start, doc.cursor],
          width: doc.bounds.width - right_col_start,
          align: :left
        )

        doc.move_down 15 # Space between rows; adjust as needed
      end
    end
  end
end
