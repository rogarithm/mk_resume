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

      typesetter = MkResume::PdfTypesetter.new
      typeset_opts = {
        :doc_writer => @doc_writer,
        :doc => doc,
        :formatting_config => @formatting_config,
        :font_manager => @font_manager,
        :layout_arranger => @layout_arranger,
        :parser => @parser
      }

      typesetter.handler(sections[:personal_info]).call(
        sections[:personal_info],
        typeset_opts
      )

      @layout_arranger.v_space(doc, 14.5)


      @doc_writer.write_heading(
        doc,
        :introduction.to_s.capitalize,
        @formatting_config.introduction(:heading, @font_manager)
      )

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

      typesetter.handler(sections[:side_project]).call(
        sections[:side_project],
        typeset_opts
      )
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
