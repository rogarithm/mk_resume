module MkResume
  class FormattingConfig
    FONT_SIZE = {:heading => 9.5, :body => 9.5, :detail => 9}

    def find_font_size usage
      FONT_SIZE[usage]
    end

    def markdown usage
      line_height = 1.45

      formatting_config = {
        :heading => {
          size: find_font_size(:heading),
          style: :bold,
          leading: line_height * find_font_size(:heading)
        },
        :h1 => {
          size: find_font_size(:heading),
          leading: 6,
          indent_paragraphs: 0,
          line_spacing_pt: 5
        },
        :h2 => {
          size: find_font_size(:heading),
          leading: 6,
          indent_paragraphs: 0,
          line_spacing_pt: 3
        },
        :h3 => {
          size: 9.5,
          leading: 6,
          indent_paragraphs: 0,
          line_spacing_pt: 2
        },
        :h4 => {
          size: find_font_size(:body),
          leading: 6,
          indent_paragraphs: 0,
          line_spacing_pt: 2
        },
        :text => {
          size: find_font_size(:body),
          leading: 6,
          indent_paragraphs: 0,
          line_spacing_pt: 2
        },
        :list_item => {
          size: find_font_size(:detail),
          leading: 4,
          indent_paragraphs: 0,
          line_spacing_pt: 2
        }
      }

      formatting_config[usage]
    end

    def method_missing(symbol, *args)
      raise FormattingConfigNotExistsError.new(
        "Formatting config for '#{symbol.to_s}' doesn't exist.
You may have forgot to add config for newly added section"
      )
    end
  end

  class FormattingConfigNotExistsError < StandardError; end
end
