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

  def print(relative_path, section_order = [
      :personal_info, :introduction, :portfolio,
      :work_experience, :side_project, :education
    ])

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
        :layout_arranger => @layout_arranger,
        :parser => @parser
      }

      sections = @doc_writer.read_sections(relative_path)
      section_order.each { |section_nm|
        typesetter.handler(sections[section_nm]).call(
          section_nm,
          sections[section_nm],
          typeset_opts
        )
      }
    end
  end
end
