require 'prawn'
require 'prawn/measurement_extensions'
require_relative 'mk_resume/section_parser'
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
    @parser = MkResume::SectionParser.new
  end

  def print(relative_path)

    sections = @doc_writer.read_sections(relative_path)

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
        :portfolio.to_s.capitalize,
        @formatting_config.portfolio(:heading, @font_manager)
      )

      portfolios = []
      @parser.segments_by_keyword(sections[:portfolio], "portfolio_nm").each do |portfolio|
        portfolios << @parser.make_obj(portfolio.join("\n"),
          [:portfolio_nm, :desc, :repo_link, :service_link, :swagger_link, :tech_stack],
          MkResume::PortfolioProjectMaker)
      end

      portfolios.each do |portfolio|
        match = portfolio[:repo_link].match(/<link href='([^']*)'>([^<]*)<\/link>/)
        link_url = match[1]
        link_text = match[2]

        @doc_writer.write_formatted_text(
          doc,
          [
            { text: portfolio[:portfolio_nm], leading: 6 },
            { text: " (" },
            { text: "#{link_text}", leading: 6, styles: [:underline], color: "888888", link: link_url },
            { text: ")" },
          ],
          @formatting_config.portfolio(:project, @font_manager)
        )
        @layout_arranger.v_space(doc, 10)

        @doc_writer.write_text(
          doc,
          portfolio[:desc],
          @formatting_config.portfolio(:default, @font_manager)
                            .merge!({:line_spacing_pt => 2})
        )

        @doc_writer.write_text(
          doc,
          "사용 기술: #{portfolio[:tech_stack]}",
          @formatting_config.portfolio(:default, @font_manager)
                            .merge!({:line_spacing_pt => 2})
        )

        @doc_writer.write_text(
          doc,
          "담당 작업",
          @formatting_config.portfolio(:default, @font_manager)
        )
        portfolio[:project][:tasks].each do |task|
          @doc_writer.write_indented_text(
            doc,
            "  ",
            "- #{task}",
            @formatting_config.portfolio(:default, @font_manager)
              .merge!({:line_spacing_pt => 2})
          )
        end
        @layout_arranger.v_space(doc, 2)

        portfolio[:project][:trouble_shooting].each do |trb_sht_info|
          trb_sht_info.each_key do |trb_sht_desc|
            @doc_writer.write_text(
              doc,
              "해결한 문제: #{trb_sht_desc}",
              @formatting_config.portfolio(:default, @font_manager)
            )

            trb_sht_info[trb_sht_desc].each do |trb_sht_detail|
              @doc_writer.write_indented_text(
                doc,
                "  ",
                "- #{trb_sht_detail}",
                @formatting_config.portfolio(:default, @font_manager)
                                  .merge!({:line_spacing_pt => 2})
              )
            end
            @layout_arranger.v_space(doc, 2)
            @layout_arranger.v_space(doc, 2)
            @layout_arranger.v_space(doc, 2)

          end
        end

        @layout_arranger.v_space(doc, 2)
        @layout_arranger.v_space(doc, 2)
        @layout_arranger.v_space(doc, 2)
      end
      @layout_arranger.v_space(doc, 2)
      @layout_arranger.v_space(doc, 14.5)


      @doc_writer.write_heading(
        doc,
        :work_experience.to_s.split("_").map(&:capitalize).join(" "),
        @formatting_config.work_experience(:heading, @font_manager)
      )

      work_exps = []
      @parser.segments_by_keyword(sections[:work_experience]).each do |work_exp|
        work_exps << @parser.make_obj(work_exp.join("\n"))
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
      @parser.segments_by_keyword(sections[:side_project], "side_proj_nm").each do |side_proj|
        side_projs << @parser.make_obj(side_proj.join("\n"), [:side_proj_nm, :proj_link, :proj_desc])
      end

      side_projs.each do |side_proj|

        match = side_proj[:proj_link].match(/<link href='([^']*)'>([^<]*)<\/link>/)
        link_url = match[1]
        link_text = match[2]

        @doc_writer.write_formatted_text(
          doc,
          [
            { text: side_proj[:side_proj_nm], leading: 6 },
            { text: " (" },
            { text: "#{link_text}", leading: 6, styles: [:underline], color: "888888", link: link_url },
            { text: ")" },
          ],
          @formatting_config.side_project(:project, @font_manager)
        )

        @layout_arranger.v_space(doc, 2)

        @doc_writer.write_indented_text(
          doc,
          "      ",
          side_proj[:proj_desc],
          @formatting_config.side_project(:default, @font_manager)
        )
        @layout_arranger.v_space(doc, 2)
        @layout_arranger.v_space(doc, 2)
        @layout_arranger.v_space(doc, 2)
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
