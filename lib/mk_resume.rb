require 'prawn'
require 'prawn/measurement_extensions'
require_relative 'preproc'

# 플레인 텍스트 형식으로 적은 이력서를 pdf로 변환하기 위한 스크립트

DOC_MARGIN = {:top => 2.cm, :right => 3.05.cm, :bottom => 2.cm, :left => 3.05.cm}

class FontManager
  FONT_SIZE = {:name => 11, :channel => 10, :heading => 9.5, :body => 9.5}

  def load_font(pdf_doc)
    Prawn::Font::AFM.hide_m17n_warning = true
    pdf_doc.font_families.update(
      "NotoSans" => {
        normal: "./fonts/NotoSansKR-Regular.ttf",
        bold: "./fonts/NotoSansKR-Bold.ttf"
      }
    )
    pdf_doc.font "NotoSans"
  end

  def find_font_size usage
    FONT_SIZE[usage]
  end
end

class DocumentWriter
  def write_text(pdf_doc, txt, options = {})
    pdf_doc.text(txt, options)
  end

  def indent(pdf_doc, left_width, &text_writer)
    pdf_doc.indent(left_width, &text_writer)
  end

  def write_text_box(pdf_doc, txt, options = {})
    pdf_doc.text_box(txt, options)
  end

  def write_formatted_text(pdf_doc, texts, options = {})
    pdf_doc.formatted_text(texts, options)
  end
end

class LayoutArranger
  def make_vertical_space(pdf_doc, point)
    pdf_doc.move_down point
  end

  alias_method :v_space, :make_vertical_space

  def draw_horizontal_rule(pdf_doc)
    pdf_doc.stroke_horizontal_rule
  end

  alias_method :h_rule, :draw_horizontal_rule

  def width_of_bounding_box(pdf_doc)
    pdf_doc.bounds.width
  end

  alias_method :bound_width, :width_of_bounding_box

  def y_position_of_bounding_box(pdf_doc)
    pdf_doc.cursor
  end

  alias_method :y_position, :y_position_of_bounding_box
end

def run(relative_path)
  link_style = "<color rgb='888888'><u>%s</u></color>"

  Prawn::Document.generate(
    "output.pdf",
    page_size: "A4",
    margin: [DOC_MARGIN[:top], DOC_MARGIN[:right], DOC_MARGIN[:bottom], DOC_MARGIN[:left]]
  ) do |doc|

    font_manager = FontManager.new
    font_manager.load_font(doc)

    doc_writer = DocumentWriter.new
    layout_arranger = LayoutArranger.new

    ["personal_info"].each do |heading|
      personal_info = File.readlines(File.join(File.dirname(__FILE__), *relative_path, *%W[personalInfo])).map(&:chomp)

      doc_writer.write_text(
        doc,
        personal_info[0],
        {
          size: font_manager.find_font_size(:name),
          style: :bold,
          leading: 8
        }
      )

      personal_info[1..2].each do |item|
        doc_writer.write_text(
          doc,
          item,
          {
            size: font_manager.find_font_size(:channel),
            leading: 5
          }
        )
      end

      doc_writer.write_text(
        doc,
        link_style % personal_info[3],
        {
          size: font_manager.find_font_size(:channel),
          leading: 5,
          inline_format: true
        }
      )

      # blog 링크
      doc_writer.write_text(
        doc,
        link_style % personal_info[4],
        {
          size: font_manager.find_font_size(:channel),
          leading: 5,
          inline_format: true
        }
      )
    end

    layout_arranger.v_space(doc, 14.5)

    [{level: 4, text: "Introduction"}].each do |heading|
      layout_arranger.draw_horizontal_rule(doc)
      layout_arranger.v_space(doc, 9.5)
      line_height = 1.45
      doc_writer.write_text(
        doc,
        heading[:text],
        {
          size: font_manager.find_font_size(:heading),
          style: :bold,
          leading: line_height * font_manager.find_font_size(:heading)
        }
      )
      intro_info = File.readlines(File.join(File.dirname(__FILE__), *relative_path, *%W[introduction])).map(&:chomp)

      intro_info.each do |item|
        doc_writer.indent(doc, doc.width_of("- ")) do
          doc_writer.write_text(
            doc,
            "- #{item}",
            {
              size: font_manager.find_font_size(:body),
              leading: 6,
              indent_paragraphs: 0
            }
          )
        end

        layout_arranger.v_space(doc, 2)
      end
    end

    layout_arranger.v_space(doc, 14.5)

    [{ level: 4, text: "Work Experience" }].each do |heading|
      layout_arranger.draw_horizontal_rule(doc)
      layout_arranger.v_space(doc, 9.5)
      line_height = 1.45
      doc_writer.write_text(
        doc,
        heading[:text],
        {
          size: font_manager.find_font_size(:heading),
          style: :bold,
          leading: line_height * font_manager.find_font_size(:heading)
        }
      )

      pp = Preproc.new
      work_info = []
      wis = pp.split_by_company(File.read(File.join(File.dirname(__FILE__), *relative_path, *%W[workExperience])))
      wis.each do |wi|
        work_info << pp.group_by_company(wi.join("\n"))
      end

      work_info.each.with_index do |wi, idx|
        doc_writer.write_text(
          doc,
          wi[:company_nm],
          {
            size: font_manager.find_font_size(:body),
            leading: 6,
            indent_paragraphs: 0
          }
        )
        layout_arranger.v_space(doc, 2)
        doc_writer.write_text(
          doc,
          "사용기술: #{wi[:skill_set]}",
          {
            size: font_manager.find_font_size(:body),
            leading: 12,
            indent_paragraphs: 0
          }
        ) if wi[:skill_set]
        layout_arranger.v_space(doc, 2) if wi[:skill_set]

        wi[:project].keys.each do |solve|
          doc_writer.write_text(
            doc,
            solve,
            {
              size: font_manager.find_font_size(:body),
              leading: 6,
              indent_paragraphs: 0
            }
          )

          what_n_details_list = wi[:project][solve]
          what_n_details_list.each do |what_n_details|
            what_n_details.each_key {|what|
              doc_writer.indent(doc, doc.width_of("      ")) do
                doc_writer.write_text(
                  doc,
                  what,
                  {
                    size: font_manager.find_font_size(:body),
                    leading: 6,
                    indent_paragraphs: 0
                  }
                )
              end if what != :EMPTY_WHAT
              details = what_n_details[what]
              details.each do |detail_item|
                doc_writer.indent(doc, doc.width_of("      ")) do
                  doc_writer.write_text(
                    doc,
                    "- #{detail_item}",
                    {
                      size: font_manager.find_font_size(:body),
                      leading: 6,
                      indent_paragraphs: 0
                    }
                  )
                end
                layout_arranger.v_space(doc, 2)
              end
              layout_arranger.v_space(doc, 2)
              layout_arranger.v_space(doc, 2)
              layout_arranger.v_space(doc, 2)
            }
          end
        end
      end
    end

    layout_arranger.v_space(doc, 2)
    layout_arranger.v_space(doc, 14.5)

    [{ level: 4, text: "Side Project" }].each do |heading|
      layout_arranger.draw_horizontal_rule(doc)
      layout_arranger.v_space(doc, 9.5)
      line_height = 1.45
      doc_writer.write_text(
        doc,
        heading[:text],
        {
          size: font_manager.find_font_size(:heading),
          style: :bold,
          leading: line_height * font_manager.find_font_size(:heading)
        }
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

            doc_writer.write_formatted_text(
              doc,
              [
                { text: spi[:company_nm], size: font_manager.find_font_size(:body), leading: 6 },
                { text: " (", size: font_manager.find_font_size(:body) },
                { text: "#{link_text}", size: font_manager.find_font_size(:body), leading: 6,
                  styles: [:underline], color: "888888", link: link_url },
                { text: ")", size: font_manager.find_font_size(:body) },
              ],
              { indent_paragraphs: 0 }
            )
          else
            doc_writer.write_formatted_text(
              doc,
              [
                { text: spi[:company_nm], size: font_manager.find_font_size(:body), leading: 6 },
                { text: " ", size: font_manager.find_font_size(:body) },
                { text: project, size: font_manager.find_font_size(:body), leading: 6 }
              ],
              { indent_paragraphs: 0 }
            )
          end

          layout_arranger.v_space(doc, 2)

          what_n_details_list = spi[:project][project]
          what_n_details_list.each do |what_n_details|
            what_n_details.each_key {|what|
              doc_writer.indent(doc, doc.width_of("      ")) do
                doc_writer.write_text(
                  doc,
                  what,
                  {
                    size: font_manager.find_font_size(:body),
                    leading: 6,
                    indent_paragraphs: 0
                  }
                )
              end if what != :EMPTY_WHAT
              details = what_n_details[what]
              details.each do |detail_item|
                doc_writer.indent(doc, doc.width_of("      ")) do
                  doc_writer.write_text(
                    doc,
                    "- #{detail_item}",
                    {
                      size: font_manager.find_font_size(:body),
                      leading: 6,
                      indent_paragraphs: 0
                    }
                  )
                end
                layout_arranger.v_space(doc, 2)
              end
              layout_arranger.v_space(doc, 2)
              layout_arranger.v_space(doc, 2)
              layout_arranger.v_space(doc, 2)
            }
          end
        end
      end
    end

    layout_arranger.v_space(doc, 2)
    layout_arranger.v_space(doc, 14.5)

    [{ level: 4, text: "Education" }].each do |heading|
      layout_arranger.draw_horizontal_rule(doc)
      layout_arranger.v_space(doc, 9.5)
      line_height = 1.45
      doc_writer.write_text(
        doc,
        heading[:text],
        {
          size: font_manager.find_font_size(:heading),
          style: :bold,
          leading: line_height * font_manager.find_font_size(:heading)
        }
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
        doc_writer.write_text_box(
          doc,
          left_text,
          {
            size: font_manager.find_font_size(:body),
            at: [0, layout_arranger.y_position(doc)],
            width: left_col_width,
            align: :left
          }
        )

        # Draw right column text, positioned to start at the right_col_start
        doc_writer.write_text_box(
          doc,
          right_text,
          {
            size: font_manager.find_font_size(:body),
            at: [right_col_start, layout_arranger.y_position(doc)],
            width: layout_arranger.bound_width(doc) - right_col_start,
            align: :left
          }
        )

        layout_arranger.v_space(doc, 15) # Space between rows; adjust as needed
      end
    end
  end
end
