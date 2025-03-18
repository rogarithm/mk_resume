module MkResume
  class DocumentWriter
    attr_reader :sections

    def initialize
      @sections = {}
    end

    def read_sections(relative_path)
      [:personal_info, :introduction, :work_experience, :side_project, :education, :portfolio].each {|file_sym|
        @sections.store(file_sym, read_file(file_sym.to_s, relative_path))
      }
      @sections
    end

    def read_file file_nm, relative_path
      File.read(File.join(File.dirname(__FILE__), *relative_path, *%W[#{file_nm}]))
    end

    def write_heading(pdf_doc, txt, options = {})
      h_rule(pdf_doc)
      line_spacing(pdf_doc, 9.5)
      write_text(
        pdf_doc,
        txt,
        options
      )
    end

    def draw_horizontal_rule(pdf_doc)
      pdf_doc.stroke_horizontal_rule
    end

    alias_method :h_rule, :draw_horizontal_rule

    def write_indented_text(pdf_doc, width2indent, txt, options = {})
      indent(pdf_doc, width2indent) do
        write_text(pdf_doc, txt, options)
      end
    end

    def write_text(pdf_doc, txt, options = {})
      txt = wrap_link(txt)
      pdf_doc.text(txt, options)

      if options[:line_spacing_pt] == nil
        line_spacing(pdf_doc, 0)
      else
        line_spacing(pdf_doc, options[:line_spacing_pt])
      end
    end

    def line_spacing(pdf_doc, point)
      pdf_doc.move_down point
    end

    def wrap_link text
      link_style = "<color rgb='888888'><u>%s</u></color>"
      link_regex = /<link href='([^']*)'>([^<]*)<\/link>/

      text.match(link_regex) ? link_style % text : text
    end

    def indent(pdf_doc, left_width, &text_writer)
      val2indent = pdf_doc.width_of(left_width)
      pdf_doc.indent(val2indent, &text_writer)
    end

    def write_text_box(pdf_doc, txt, options = {})
      pdf_doc.text_box(txt, options)
    end

    def write_formatted_text(pdf_doc, texts, options = {})
      pdf_doc.formatted_text(texts, options)
    end
  end
end
