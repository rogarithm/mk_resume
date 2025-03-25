module MkResume
  class FormattingConfig
    FONT_SIZE = {:name => 11, :channel => 10, :heading => 9.5, :body => 9.5}

    def find_font_size usage
      FONT_SIZE[usage]
    end

    def personal_info line_no
      formatting_config = [
        {
          size: find_font_size(:name),
          style: :bold,
          leading: 8
        },
        {
          size: find_font_size(:channel),
          leading: 5
        },
        {
          size: find_font_size(:channel),
          leading: 5
        },
        {
          size: find_font_size(:channel),
          leading: 5,
          inline_format: true
        },
        {
          size: find_font_size(:channel),
          leading: 5,
          inline_format: true
        }
      ]
      formatting_config[line_no]
    end

    def introduction usage
      line_height = 1.45

      formatting_config = {
        :heading => {
          size: find_font_size(:heading),
          style: :bold,
          leading: line_height * find_font_size(:heading)
        },
        :default => {
          size: find_font_size(:body),
          leading: 6,
          indent_paragraphs: 0
        }
      }

      formatting_config[usage]
    end

    def work_experience usage
      line_height = 1.45

      formatting_config = {
        :heading => {
          size: find_font_size(:heading),
          style: :bold,
          leading: line_height * find_font_size(:heading)
        },
        :default => {
          size: find_font_size(:body),
          leading: 6,
          indent_paragraphs: 0
        },
        :long_leading => {
          size: find_font_size(:body),
          leading: 12,
          indent_paragraphs: 0
        }
      }

      formatting_config[usage]
    end

    def side_project usage
      line_height = 1.45

      formatting_config = {
        :heading => {
          size: find_font_size(:heading),
          style: :bold,
          leading: line_height * find_font_size(:heading)
        },
        :project => {
          size: find_font_size(:body),
          indent_paragraphs: 0
        },
        :default => {
          size: find_font_size(:body),
          leading: 6,
          indent_paragraphs: 0
        }
      }

      formatting_config[usage]
    end

    def portfolio usage
      line_height = 1.45

      formatting_config = {
        :heading => {
          size: find_font_size(:heading),
          style: :bold,
          leading: line_height * find_font_size(:heading)
        },
        :project => {
          size: find_font_size(:body),
          indent_paragraphs: 0
        },
        :default => {
          size: find_font_size(:body),
          leading: 6,
          indent_paragraphs: 0
        }
      }

      formatting_config[usage]
    end

    def education usage, doc
      line_height = 1.45
      left_col_width = 180 # Adjust based on content and page layout needs
      right_col_start = left_col_width + 10 # Spacing between columns

      formatting_config = {
        :heading => {
          size: find_font_size(:heading),
          style: :bold,
          leading: line_height * find_font_size(:heading)
        },
        :left => {
          size: find_font_size(:body),
          at: [0, y_position(doc)],
          width: left_col_width,
          align: :left
        },
        :right => {
          size: find_font_size(:body),
          at: [right_col_start, y_position(doc)],
          width: bound_width(doc) - right_col_start,
          align: :left
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

    def width_of_bounding_box(pdf_doc)
      pdf_doc.bounds.width
    end

    alias_method :bound_width, :width_of_bounding_box

    def y_position_of_bounding_box(pdf_doc)
      pdf_doc.cursor
    end

    alias_method :y_position, :y_position_of_bounding_box
  end

  class FormattingConfigNotExistsError < StandardError; end
end
