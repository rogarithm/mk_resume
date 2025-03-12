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

  def read_file file_nm, relative_path
    File.read(File.join(File.dirname(__FILE__), *relative_path, *%W[#{file_nm}]))
  end

  def run(relative_path)

    sections = {}
    [:personal_info, :introduction, :work_experience, :side_project, :education].each {|file_sym|
      sections.store(file_sym, read_file(file_sym.to_s, relative_path))
    }

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
        sections[:personal_info].split("\n")[0..4].each.with_index do |text, idx|
          @doc_writer.write_text(
            doc,
            text,
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
        sections[:introduction].split("\n").each do |text|
          @doc_writer.indent(doc, doc.width_of("- ")) do
            @doc_writer.write_text(
              doc,
              "- #{text}",
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
        @doc_writer.write_text(
          doc,
          heading[:text],
          @formatting_config.work_experience(:heading, @font_manager)
        )

        work_info = []
        @preproc.split_by_company(sections[:work_experience]).each do |wi|
          work_info << @preproc.group_by_company(wi.join("\n"))
        end

        work_info.each.with_index do |wi, idx|
          @doc_writer.write_text(
            doc,
            wi[:company_nm],
            @formatting_config.work_experience(:default, @font_manager)
          )
          @layout_arranger.v_space(doc, 2)
          @doc_writer.write_text(
            doc,
            "사용기술: #{wi[:skill_set]}",
            @formatting_config.work_experience(:long_leading, @font_manager)
          ) if wi[:skill_set]
          @layout_arranger.v_space(doc, 2) if wi[:skill_set]

          wi[:project].keys.each do |task|
            @doc_writer.write_text(
              doc,
              task,
              @formatting_config.work_experience(:default, @font_manager)
            )

            wi[:project][task].each do |task_info|
              task_info.each_key {|task_desc|
                @doc_writer.indent(doc, doc.width_of("      ")) do
                  @doc_writer.write_text(
                    doc,
                    task_desc,
                    @formatting_config.work_experience(:default, @font_manager)
                  )
                end if task_desc != :EMPTY_TASK_DESC
                task_details = task_info[task_desc]
                task_details.each do |task_detail|
                  @doc_writer.indent(doc, doc.width_of("      ")) do
                    @doc_writer.write_text(
                      doc,
                      "- #{task_detail}",
                      @formatting_config.work_experience(:default, @font_manager)
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
        @doc_writer.write_text(
          doc,
          heading[:text],
          @formatting_config.side_project(:heading, @font_manager)
        )

        side_project_info = []
        @preproc.split_by_company(sections[:side_project]).each do |wi|
          side_project_info << @preproc.group_by_company(wi.join("\n"))
        end

        side_project_info.each do |spi|
          spi[:project].keys.each do |task|

            if task.match(/<link href='([^']*)'>([^<]*)<\/link>/)
              link_url = Regexp.last_match(1)
              link_text = Regexp.last_match(2)

              @doc_writer.write_formatted_text(
                doc,
                [
                  { text: spi[:company_nm], leading: 6 },
                  { text: " (" },
                  { text: "#{link_text}", leading: 6, styles: [:underline], color: "888888", link: link_url },
                  { text: ")" },
                ],
                @formatting_config.side_project(:project, @font_manager)
              )
            else
              @doc_writer.write_formatted_text(
                doc,
                [
                  { text: spi[:company_nm],  leading: 6 },
                  { text: " " },
                  { text: task, leading: 6 }
                ],
                @formatting_config.side_project(:project, @font_manager)
              )
            end

            @layout_arranger.v_space(doc, 2)

            spi[:project][task].each do |task_info|
              task_info.each_key {|task|
                @doc_writer.indent(doc, doc.width_of("      ")) do
                  @doc_writer.write_text(
                    doc,
                    task,
                    @formatting_config.side_project(:default, @font_manager)
                  )
                end if task != :EMPTY_TASK_DESC
                task_details = task_info[task]
                task_details.each do |detail_item|
                  @doc_writer.indent(doc, doc.width_of("      ")) do
                    @doc_writer.write_text(
                      doc,
                      "- #{detail_item}",
                      @formatting_config.side_project(:default, @font_manager)
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
        @doc_writer.write_text(
          doc,
          heading[:text],
          @formatting_config.education(:heading, @font_manager, doc)
        )

        sections[:education].split("\n")
                            .map! { |cols|
                              cols.split(",")
                                  .each { |col| col.strip! }
                            }.each do |left_text, right_text|
          # Draw left column text
          @doc_writer.write_text_box(
            doc,
            left_text,
            @formatting_config.education(:left, @font_manager, doc)
          )

          # Draw right column text, positioned to start at the right_col_start
          @doc_writer.write_text_box(
            doc,
            right_text,
            @formatting_config.education(:right, @font_manager, doc)
          )

          @layout_arranger.v_space(doc, 15) # Space between rows; adjust as needed
        end
      end
    end
  end
end
