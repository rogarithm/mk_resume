module MkResume
  class DocumentWriter
    def write_text(pdf_doc, txt, options = {})
      txt = wrap_link(txt)
      pdf_doc.text(txt, options)
    end

    def wrap_link text
      link_style = "<color rgb='888888'><u>%s</u></color>"
      link_regex = /<link href='([^']*)'>([^<]*)<\/link>/

      text.match(link_regex) ? link_style % text : text
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
end
