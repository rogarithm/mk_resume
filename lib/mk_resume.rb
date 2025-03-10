require 'prawn'
require 'prawn/measurement_extensions'
require_relative 'mk_resume/preproc'
require_relative 'mk_resume/font_manager'
require_relative 'mk_resume/document_writer'
require_relative 'mk_resume/layout_arranger'
require_relative 'mk_resume/formatting_config'

# 플레인 텍스트 형식으로 적은 이력서를 pdf로 변환하기 위한 스크립트

class ResumePrinter
  def initialize
    @layout_arranger = MkResume::LayoutArranger.new
    @font_manager = MkResume::FontManager.new
    @formatting_config = MkResume::FormattingConfig.new
    @doc_writer = MkResume::DocumentWriter.new
    @preproc = MkResume::Preproc.new
  end

  def run(relative_path)
    Prawn::Document.generate(
      "output.pdf",
      page_size: "A4",
      margin: [
        @layout_arranger.find_margin_size(:top),
        @layout_arranger.find_margin_size(:right),
        @layout_arranger.find_margin_size(:bottom),
        @layout_arranger.find_margin_size(:left)
      ]
    ) do |doc|

      @font_manager.load_font(doc)

      ["personal_info"].each do |heading|
        personal_info = File.readlines(File.join(File.dirname(__FILE__), *relative_path, *%W[personalInfo])).map(&:chomp)

        personal_info[0..4].each.with_index do |item, idx|
          @doc_writer.write_text(
            doc,
            item,
            @formatting_config.personal_info(idx, @font_manager)
          )
        end
      end

      @layout_arranger.v_space(doc, 14.5)

      [{level: 4, text: "Introduction"}].each do |heading|
        @layout_arranger.draw_horizontal_rule(doc)
        @layout_arranger.v_space(doc, 9.5)
        @doc_writer.write_text(
          doc,
          heading[:text],
          @formatting_config.introduction(:heading, @font_manager)
        )
        intro_info = File.readlines(File.join(File.dirname(__FILE__), *relative_path, *%W[introduction])).map(&:chomp)

        intro_info.each do |item|
          @doc_writer.indent(doc, doc.width_of("- ")) do
            @doc_writer.write_text(
              doc,
              "- #{item}",
              @formatting_config.introduction(:default, @font_manager)
            )
          end

          @layout_arranger.v_space(doc, 2)
        end
      end

      @layout_arranger.v_space(doc, 14.5)

      [{ level: 4, text: "Work Experience" }].each do |heading|
        @layout_arranger.draw_horizontal_rule(doc)
        @layout_arranger.v_space(doc, 9.5)
        line_height = 1.45
        @doc_writer.write_text(
          doc,
          heading[:text],
          {
            size: @font_manager.find_font_size(:heading),
            style: :bold,
            leading: line_height * @font_manager.find_font_size(:heading)
          }
        )

        work_info = []
        wis = @preproc.split_by_company(File.read(File.join(File.dirname(__FILE__), *relative_path, *%W[workExperience])))
        wis.each do |wi|
          work_info << @preproc.group_by_company(wi.join("\n"))
        end

        work_info.each.with_index do |wi, idx|
          @doc_writer.write_text(
            doc,
            wi[:company_nm],
            {
              size: @font_manager.find_font_size(:body),
              leading: 6,
              indent_paragraphs: 0
            }
          )
          @layout_arranger.v_space(doc, 2)
          @doc_writer.write_text(
            doc,
            "사용기술: #{wi[:skill_set]}",
            {
              size: @font_manager.find_font_size(:body),
              leading: 12,
              indent_paragraphs: 0
            }
          ) if wi[:skill_set]
          @layout_arranger.v_space(doc, 2) if wi[:skill_set]

          wi[:project].keys.each do |solve|
            @doc_writer.write_text(
              doc,
              solve,
              {
                size: @font_manager.find_font_size(:body),
                leading: 6,
                indent_paragraphs: 0
              }
            )

            what_n_details_list = wi[:project][solve]
            what_n_details_list.each do |what_n_details|
              what_n_details.each_key {|what|
                @doc_writer.indent(doc, doc.width_of("      ")) do
                  @doc_writer.write_text(
                    doc,
                    what,
                    {
                      size: @font_manager.find_font_size(:body),
                      leading: 6,
                      indent_paragraphs: 0
                    }
                  )
                end if what != :EMPTY_WHAT
                details = what_n_details[what]
                details.each do |detail_item|
                  @doc_writer.indent(doc, doc.width_of("      ")) do
                    @doc_writer.write_text(
                      doc,
                      "- #{detail_item}",
                      {
                        size: @font_manager.find_font_size(:body),
                        leading: 6,
                        indent_paragraphs: 0
                      }
                    )
                  end
                  @layout_arranger.v_space(doc, 2)
                end
                @layout_arranger.v_space(doc, 2)
                @layout_arranger.v_space(doc, 2)
                @layout_arranger.v_space(doc, 2)
              }
            end
          end
        end
      end

      @layout_arranger.v_space(doc, 2)
      @layout_arranger.v_space(doc, 14.5)

      [{ level: 4, text: "Side Project" }].each do |heading|
        @layout_arranger.draw_horizontal_rule(doc)
        @layout_arranger.v_space(doc, 9.5)
        line_height = 1.45
        @doc_writer.write_text(
          doc,
          heading[:text],
          {
            size: @font_manager.find_font_size(:heading),
            style: :bold,
            leading: line_height * @font_manager.find_font_size(:heading)
          }
        )

        side_project_info = []
        wis = @preproc.split_by_company(File.read(File.join(File.dirname(__FILE__), *relative_path, *%W[sideProject])))
        wis.each do |wi|
          side_project_info << @preproc.group_by_company(wi.join("\n"))
        end

        side_project_info.each do |spi|
          spi[:project].keys.each do |project|

            if project.match(/<link href='([^']*)'>([^<]*)<\/link>/)
              link_url = Regexp.last_match(1)
              link_text = Regexp.last_match(2)

              @doc_writer.write_formatted_text(
                doc,
                [
                  { text: spi[:company_nm], size: @font_manager.find_font_size(:body), leading: 6 },
                  { text: " (", size: @font_manager.find_font_size(:body) },
                  { text: "#{link_text}", size: @font_manager.find_font_size(:body), leading: 6,
                    styles: [:underline], color: "888888", link: link_url },
                  { text: ")", size: @font_manager.find_font_size(:body) },
                ],
                { indent_paragraphs: 0 }
              )
            else
              @doc_writer.write_formatted_text(
                doc,
                [
                  { text: spi[:company_nm], size: @font_manager.find_font_size(:body), leading: 6 },
                  { text: " ", size: @font_manager.find_font_size(:body) },
                  { text: project, size: @font_manager.find_font_size(:body), leading: 6 }
                ],
                { indent_paragraphs: 0 }
              )
            end

            @layout_arranger.v_space(doc, 2)

            what_n_details_list = spi[:project][project]
            what_n_details_list.each do |what_n_details|
              what_n_details.each_key {|what|
                @doc_writer.indent(doc, doc.width_of("      ")) do
                  @doc_writer.write_text(
                    doc,
                    what,
                    {
                      size: @font_manager.find_font_size(:body),
                      leading: 6,
                      indent_paragraphs: 0
                    }
                  )
                end if what != :EMPTY_WHAT
                details = what_n_details[what]
                details.each do |detail_item|
                  @doc_writer.indent(doc, doc.width_of("      ")) do
                    @doc_writer.write_text(
                      doc,
                      "- #{detail_item}",
                      {
                        size: @font_manager.find_font_size(:body),
                        leading: 6,
                        indent_paragraphs: 0
                      }
                    )
                  end
                  @layout_arranger.v_space(doc, 2)
                end
                @layout_arranger.v_space(doc, 2)
                @layout_arranger.v_space(doc, 2)
                @layout_arranger.v_space(doc, 2)
              }
            end
          end
        end
      end

      @layout_arranger.v_space(doc, 2)
      @layout_arranger.v_space(doc, 14.5)

      [{ level: 4, text: "Education" }].each do |heading|
        @layout_arranger.draw_horizontal_rule(doc)
        @layout_arranger.v_space(doc, 9.5)
        line_height = 1.45
        @doc_writer.write_text(
          doc,
          heading[:text],
          {
            size: @font_manager.find_font_size(:heading),
            style: :bold,
            leading: line_height * @font_manager.find_font_size(:heading)
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
          @doc_writer.write_text_box(
            doc,
            left_text,
            {
              size: @font_manager.find_font_size(:body),
              at: [0, @layout_arranger.y_position(doc)],
              width: left_col_width,
              align: :left
            }
          )

          # Draw right column text, positioned to start at the right_col_start
          @doc_writer.write_text_box(
            doc,
            right_text,
            {
              size: @font_manager.find_font_size(:body),
              at: [right_col_start, @layout_arranger.y_position(doc)],
              width: @layout_arranger.bound_width(doc) - right_col_start,
              align: :left
            }
          )

          @layout_arranger.v_space(doc, 15) # Space between rows; adjust as needed
        end
      end
    end
  end
end
