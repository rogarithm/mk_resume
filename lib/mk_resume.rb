require 'prawn'
require 'prawn/measurement_extensions'
require_relative 'mk_resume/section_parser'
require_relative 'mk_resume/font_manager'
require_relative 'mk_resume/document_writer'
require_relative 'mk_resume/layout_arranger'
require_relative 'mk_resume/formatting_config'
require_relative 'mk_resume/pdf_typesetter'

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

      typesetter = MkResume::PdfTypesetter.new
      typeset_opts = {
        :doc_writer => @doc_writer,
        :doc => doc,
        :formatting_config => @formatting_config,
        :font_manager => @font_manager,
        :layout_arranger => @layout_arranger,
        :parser => @parser
      }
      typesetter.handler(sections[:introduction]).call(
        sections[:introduction],
        typeset_opts
      )

      @layout_arranger.v_space(doc, 14.5)


      @doc_writer.write_heading(
        doc,
        :portfolio.to_s.capitalize,
        @formatting_config.portfolio(:heading, @font_manager)
      )

      typesetter.handler(sections[:portfolio]).call(
        sections[:portfolio],
        typeset_opts
      )
      @layout_arranger.v_space(doc, 2)
      @layout_arranger.v_space(doc, 14.5)


      @doc_writer.write_heading(
        doc,
        :work_experience.to_s.split("_").map(&:capitalize).join(" "),
        @formatting_config.work_experience(:heading, @font_manager)
      )

      typesetter.handler(sections[:work_experience]).call(
        sections[:work_experience],
        typeset_opts
      )
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

      typesetter.handler(sections[:education]).call(
        sections[:education],
        typeset_opts
      )
    end
  end
end
