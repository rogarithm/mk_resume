module MkResume
  class DocumentWriter
    attr_reader :sections

    def initialize
      @sections = {}
    end

    def read_sections(relative_path)
      Dir.entries(File.join(File.dirname(__FILE__), *relative_path))
         .reject {|entry| entry.match?(/^\..*$/)} # 반환값 중 필요 없는 ., .., .DS_Store 를 제외한다
         .map {|entry| entry.to_sym}
         .each {|file_sym| @sections.store(file_sym, read_file(file_sym.to_s, relative_path))}

      @sections
    end

    def read_file file_nm, relative_path
      File.read(File.join(File.dirname(__FILE__), *relative_path, *%W[#{file_nm}]))
    end

    def write_heading(pdf_doc, heading_sym, options = {})
      h_rule(pdf_doc)
      line_spacing(pdf_doc, 9.5)
      write_text(
        pdf_doc,
        capitalize(heading_sym),
        options
      )
    end

    def capitalize(section_title_sym)
      section_title = section_title_sym.to_s

      if section_title.match?(/.*_.*/) == false
        section_title.capitalize
      end

      section_title.split("_").map(&:capitalize).join(" ")
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

    def find_txt_type(text)
      txt_type = {
        :simple_text => false,
        :only_link => false,
        :text_link_combined => false
      }
      link_regex = /\[([^\]]+)\]\(([^)]+)\)/

      # scan을 사용해서 모든 링크 매칭 확인
      matches = text.scan(link_regex)

      if matches.empty?
        txt_type[:simple_text] = true
        return txt_type
      end

      # 모든 링크를 제거한 텍스트가 비어있으면 링크만 있는 것
      text_without_links = text.gsub(link_regex, '')
      txt_type[:only_link] = true if text_without_links.strip.empty?
      txt_type[:text_link_combined] = true if !text_without_links.strip.empty?
      txt_type
    end

    def write_text(pdf_doc, txt, options = {})
      txt_type = find_txt_type(txt)
      if txt_type[:simple_text]
        pdf_doc.text(txt, options)
      end
      if txt_type[:only_link]
        txt = wrap_link(txt)
        pdf_doc.text(txt, options)
      end
      if txt_type[:text_link_combined]
        wrapped_txt = wrap_link_n_txt txt

        write_formatted_text(
          pdf_doc,
          wrapped_txt,
          options
        )
      end

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
      link_regex = /\[([^\]]+)\]\(([^)]+)\)/

      text.match(link_regex) ? link_style % text : text
    end

    def wrap_link_n_txt txt
      result = []
      link_regex = /\[([^\]]+)\]\(([^)]+)\)/
      remaining_text = txt

      # 텍스트를 순회하면서 모든 링크를 찾아 처리
      while match = remaining_text.match(link_regex)
        # 링크 앞의 텍스트가 있으면 추가
        before_text = match.pre_match
        if !before_text.empty?
          result << { text: before_text, leading: 6 }
        end

        # 링크 추가
        result << {
          text: match[1],  # 링크 텍스트
          leading: 6,
          styles: [:underline],
          color: "888888",
          link: match[2]  # 링크 URL
        }

        # 나머지 텍스트로 계속 진행
        remaining_text = match.post_match
      end

      # 마지막 링크 이후의 텍스트가 있으면 추가
      if !remaining_text.empty?
        result << { text: remaining_text, leading: 6 }
      end

      result
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
