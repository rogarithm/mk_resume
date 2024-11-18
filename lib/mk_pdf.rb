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

DOC_MARGIN = {:top => 2.cm, :right => 3.05.cm, :bottom => 2.cm, :left => 3.05.cm}
FONT_SIZE = {:heading => 9.5, :body => 9.5}

Prawn::Document.generate(
  "output.pdf",
  page_size: "A4",
  margin: [DOC_MARGIN[:top], DOC_MARGIN[:right], DOC_MARGIN[:bottom], DOC_MARGIN[:left]]
) do

  load_font

  [{level: 4, text: "Introduction"}].each do |heading|
    draw_heading(heading, FONT_SIZE)

    intro_info = File.readlines(File.join(File.dirname(__FILE__), "../src/introduction")).map(&:chomp)

    intro_info.each do |item|
      indent(width_of("- ")) do
        text(
          "- #{item}",
          size: FONT_SIZE[:body],
          leading: 8,
          indent_paragraphs: 0
        )
      end

      space_after_list_item
    end
  end

  space_after_paragraph

  [{ level: 4, text: "Education" }].each do |heading|
    draw_heading(heading, FONT_SIZE)

    education_info = File.readlines(File.join(File.dirname(__FILE__), "../src/education"))
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

  space_after_paragraph

  [{ level: 4, text: "Work Experience" }].each do |heading|
    draw_heading(heading, FONT_SIZE)

    pp = Preproc.new
    work_info = []
    wis = pp.split_by_company(File.read(File.join(File.dirname(__FILE__), "../src/work_experience")))
    wis.each do |wi|
      work_info << pp.group_by_company(wi.join("\n"))
    end

    work_info.each do |wi|
        text(
          wi[:company_nm],
          size: FONT_SIZE[:body],
          leading: 8,
          indent_paragraphs: 0
        )
        space_after_list_item
        text(
          wi[:work_from_to],
          size: FONT_SIZE[:body],
          leading: 8,
          indent_paragraphs: 0
        )
        space_after_list_item

        wi[:solved].keys.each do |solve|
          text(
            solve,
            size: FONT_SIZE[:body],
            leading: 8,
            indent_paragraphs: 0
          )

          what_n_details_list = wi[:solved][solve]
          what_n_details_list.each do |what_n_details|
            what_n_details.each_key {|what|
              indent(width_of("  ")) do
                text(
                  what,
                  size: FONT_SIZE[:body],
                  leading: 8,
                  indent_paragraphs: 0
                )
              end if what != :EMPTY_WHAT
              details = what_n_details[what]
              details.each do |detail_item|
                indent(width_of("- ")) do
                  text(
                    "- #{detail_item}",
                    size: FONT_SIZE[:body],
                    leading: 8,
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

  headings = [
    # { level: 4, text: "Portfolio" }
  ]
end
