require 'prawn'
require 'prawn/measurement_extensions'
require_relative 'preproc'

# 플레인 텍스트 형식으로 적은 이력서를 pdf로 변환하기 위한 스크립트

def load_font
  Prawn::Font::AFM.hide_m17n_warning = true
  font_families.update(
    "NotoSans" => {
      normal: "./fonts/NotoSansKR-Regular.ttf",
      bold: "./fonts/NotoSansKR-Bold.ttf"
    }
  )
  font "NotoSans"
end

def draw_horizontal_line
  stroke_horizontal_rule
  move_down 9.5
end

def space_after_list_item
  move_down 2
end

def space_after_paragraph
  move_down 14.5
end

def draw_heading heading, font_size
  draw_horizontal_line
  line_height = 1.45
  text(
    heading[:text],
    size: font_size[:heading],
    style: :bold,
    leading: line_height * font_size[:heading]
  )
end

link_style = "<color rgb='888888'><u>%s</u></color>"

DOC_MARGIN = {:top => 2.cm, :right => 3.05.cm, :bottom => 2.cm, :left => 3.05.cm}
FONT_SIZE = {:name => 11, :channel => 10, :heading => 9.5, :body => 9.5}

Prawn::Document.generate(
  "output.pdf",
  page_size: "A4",
  margin: [DOC_MARGIN[:top], DOC_MARGIN[:right], DOC_MARGIN[:bottom], DOC_MARGIN[:left]]
) do

  load_font

  ["personal_info"].each do |heading|
    personal_info = File.readlines(File.join(File.dirname(__FILE__), *%W[.. .. src personalInfo])).map(&:chomp)

    text(
      personal_info[0],
      size: FONT_SIZE[:name],
      style: :bold,
      leading: 8
    )

    personal_info[1..2].each do |item|
        text(
          item,
          size: FONT_SIZE[:channel],
          leading: 5,
        )
    end

    text(
      link_style % personal_info[3],
      size: FONT_SIZE[:channel],
      leading: 5,
      inline_format: true
    )
  end

  space_after_paragraph

  [{level: 4, text: "Introduction"}].each do |heading|
    draw_heading(heading, FONT_SIZE)
    intro_info = File.readlines(File.join(File.dirname(__FILE__), *%W[.. .. src introduction])).map(&:chomp)

    intro_info.each do |item|
      indent(width_of("- ")) do
        text(
          "- #{item}",
          size: FONT_SIZE[:body],
          leading: 6,
          indent_paragraphs: 0
        )
      end

      space_after_list_item
    end
  end

  space_after_paragraph

  [{ level: 4, text: "Education" }].each do |heading|
    draw_heading(heading, FONT_SIZE)

    education_info = File.readlines(File.join(File.dirname(__FILE__), *%W[.. .. src education]))
                       .map! { |cols|
                         cols.split(",")
                             .each { |col| col.strip! }
                       }

    left_col_width = 180 # Adjust based on content and page layout needs
    right_col_start = left_col_width + 10 # Spacing between columns
    education_info.each do |left_text, right_text|
      # Draw left column text
      text_box(
        left_text,
        size: FONT_SIZE[:body],
        at: [0, cursor],
        width: left_col_width,
        align: :left
      )

      # Draw right column text, positioned to start at the right_col_start
      text_box(
        right_text,
        size: FONT_SIZE[:body],
        at: [right_col_start, cursor],
        width: bounds.width - right_col_start,
        align: :left
      )

      move_down 15 # Space between rows; adjust as needed
    end
  end

  space_after_list_item
  space_after_paragraph

  [{ level: 4, text: "Work Experience" }].each do |heading|
    draw_heading(heading, FONT_SIZE)

    pp = Preproc.new
    work_info = []
    wis = pp.split_by_company(File.read(File.join(File.dirname(__FILE__), *%W[.. .. src workExperience])))
    wis.each do |wi|
      work_info << pp.group_by_company(wi.join("\n"))
    end

    work_info.each.with_index do |wi, idx|
        text(
          wi[:company_nm],
          size: FONT_SIZE[:body],
          leading: 6,
          indent_paragraphs: 0
        )
        space_after_list_item
        text(
          "사용기술: #{wi[:skill_set]}",
          size: FONT_SIZE[:body],
          leading: 12,
          indent_paragraphs: 0
        ) if wi[:skill_set]
        space_after_list_item if wi[:skill_set]

        wi[:project].keys.each do |solve|
          text(
            solve,
            size: FONT_SIZE[:body],
            leading: 6,
            indent_paragraphs: 0
          )

          what_n_details_list = wi[:project][solve]
          what_n_details_list.each do |what_n_details|
            what_n_details.each_key {|what|
              indent(width_of("      ")) do
                text(
                  what,
                  size: FONT_SIZE[:body],
                  leading: 6,
                  indent_paragraphs: 0
                )
              end if what != :EMPTY_WHAT
              details = what_n_details[what]
              details.each do |detail_item|
                indent(width_of("      ")) do
                  text(
                    "- #{detail_item}",
                    size: FONT_SIZE[:body],
                    leading: 6,
                    indent_paragraphs: 0
                  )
                end
                space_after_list_item
              end
              space_after_list_item
              space_after_list_item
              space_after_list_item
            }
          end
        end
        start_new_page if idx == 0
    end
  end

  space_after_list_item
  space_after_paragraph

  [{ level: 4, text: "Side Project" }].each do |heading|
    draw_heading(heading, FONT_SIZE)

    pp = Preproc.new
    toy_project_info = []
    wis = pp.split_by_company(File.read(File.join(File.dirname(__FILE__), *%W[.. .. src sideProject])))
    wis.each do |wi|
      toy_project_info << pp.group_by_company(wi.join("\n"))
    end

    toy_project_info.each do |tpi|
      tpi[:project].keys.each do |project|

        if project.match(/<link href='([^']*)'>([^<]*)<\/link>/)
          link_url = Regexp.last_match(1)
          link_text = Regexp.last_match(2)

          formatted_text([
            { text: tpi[:company_nm], size: FONT_SIZE[:body], leading: 6 },
            { text: " (", size: FONT_SIZE[:body] },
            { text: "#{link_text}", size: FONT_SIZE[:body], leading: 6, styles: [:underline], color: "888888", link: link_url },
            { text: ")", size: FONT_SIZE[:body] },
          ], indent_paragraphs: 0)
        else
          formatted_text([
            { text: tpi[:company_nm], size: FONT_SIZE[:body], leading: 6 },
            { text: " ", size: FONT_SIZE[:body] },
            { text: project, size: FONT_SIZE[:body], leading: 6 }
          ], indent_paragraphs: 0)
        end

        space_after_list_item

        what_n_details_list = tpi[:project][project]
        what_n_details_list.each do |what_n_details|
          what_n_details.each_key {|what|
            indent(width_of("      ")) do
              text(
                what,
                size: FONT_SIZE[:body],
                leading: 6,
                indent_paragraphs: 0
              )
            end if what != :EMPTY_WHAT
            details = what_n_details[what]
            details.each do |detail_item|
              indent(width_of("      ")) do
                text(
                  "- #{detail_item}",
                  size: FONT_SIZE[:body],
                  leading: 6,
                  indent_paragraphs: 0
                )
              end
              space_after_list_item
            end
            space_after_list_item
            space_after_list_item
            space_after_list_item
          }
        end
      end
    end
  end
end
