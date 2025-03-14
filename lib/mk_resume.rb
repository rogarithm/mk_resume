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
      margin: @layout_arranger.doc_margins
    ) do |doc|

      @font_manager.load_font(doc)

      sections[:personal_info].split("\n")[0..4].each.with_index do |text, idx|
        @doc_writer.write_text(
          doc,
          text,
          @formatting_config.personal_info(idx, @font_manager)
        )
      end
      @layout_arranger.v_space(doc, 14.5)


      @doc_writer.write_heading(
        doc,
        :introduction.to_s.capitalize,
        @formatting_config.introduction(:heading, @font_manager)
      )

      sections[:introduction].split("\n").each do |text|
        @doc_writer.write_indented_text(
          doc,
          "- ",
          "- #{text}",
          @formatting_config.introduction(:default, @font_manager)
            .merge!({:line_spacing_pt => 2})
        )
      end
      @layout_arranger.v_space(doc, 14.5)

      @doc_writer.write_heading(
        doc,
        :work_experience.to_s.split("_").map(&:capitalize).join(" "),
        @formatting_config.work_experience(:heading, @font_manager)
      )

      work_exps = []
      @preproc.split_by_company(sections[:work_experience]).each do |work_exp|
        work_exps << @preproc.group_by_company(work_exp.join("\n"))
      end

      work_exps.each do |work_exp|
        @doc_writer.write_text(
          doc,
          work_exp[:company_nm],
          @formatting_config.work_experience(:default, @font_manager)
          .merge!({:line_spacing_pt => 2})
        )
        @doc_writer.write_text(
          doc,
          "사용기술: #{work_exp[:skill_set]}",
          @formatting_config.work_experience(:long_leading, @font_manager)
            .merge!({:line_spacing_pt => 2})
        ) if work_exp[:skill_set]

        work_exp[:project].keys.each do |task|
          @doc_writer.write_text(
            doc,
            task,
            @formatting_config.work_experience(:default, @font_manager)
          )

          work_exp[:project][task].each do |task_info|
            task_info.each_key {|task_desc|
              @doc_writer.write_indented_text(
                doc,
                "      ",
                task_desc,
                @formatting_config.work_experience(:default, @font_manager)
              ) if task_desc != :EMPTY_TASK_DESC
              task_details = task_info[task_desc]
              task_details.each do |task_detail|
                @doc_writer.write_indented_text(
                  doc,
                  "      ",
                  "- #{task_detail}",
                  @formatting_config.work_experience(:default, @font_manager)
                    .merge!({:line_spacing_pt => 2})
                )
              end
              @layout_arranger.v_space(doc, 2)
              @layout_arranger.v_space(doc, 2)
              @layout_arranger.v_space(doc, 2)
            }
          end
        end
      end
      @layout_arranger.v_space(doc, 2)
      @layout_arranger.v_space(doc, 14.5)


      @doc_writer.write_heading(
        doc,
        :side_project.to_s.split("_").map(&:capitalize).join(" "),
        @formatting_config.side_project(:heading, @font_manager)
      )

      side_projs = []
      @preproc.split_by_company(sections[:side_project]).each do |side_proj|
        side_projs << @preproc.group_by_company(side_proj.join("\n"))
      end

      side_projs.each do |side_proj|
        side_proj[:project].keys.each do |task|

          if task.match(/<link href='([^']*)'>([^<]*)<\/link>/)
            link_url = Regexp.last_match(1)
            link_text = Regexp.last_match(2)

            @doc_writer.write_formatted_text(
              doc,
              [
                { text: side_proj[:company_nm], leading: 6 },
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
                { text: side_proj[:company_nm],  leading: 6 },
                { text: " " },
                { text: task, leading: 6 }
              ],
              @formatting_config.side_project(:project, @font_manager)
            )
          end

          @layout_arranger.v_space(doc, 2)

          side_proj[:project][task].each do |task_info|
            task_info.each_key {|task|
              @doc_writer.write_indented_text(
                doc,
                "      ",
                task,
                @formatting_config.side_project(:default, @font_manager)
              ) if task != :EMPTY_TASK_DESC
              task_details = task_info[task]
              task_details.each do |detail_item|
                @doc_writer.write_indented_text(
                  doc,
                  "      ",
                  "- #{detail_item}",
                  @formatting_config.side_project(:default, @font_manager)
                    .merge!({:line_spacing_pt => 2})
                )
              end
              @layout_arranger.v_space(doc, 2)
              @layout_arranger.v_space(doc, 2)
              @layout_arranger.v_space(doc, 2)
            }
          end
        end
      end
      @layout_arranger.v_space(doc, 2)
      @layout_arranger.v_space(doc, 14.5)

      @doc_writer.write_heading(
        doc,
        :education.to_s.capitalize,
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
