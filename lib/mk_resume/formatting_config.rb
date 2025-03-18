module MkResume
  class FormattingConfig
    def personal_info line_no, font_manager
      formatting_config = [
        {
          size: font_manager.find_font_size(:name),
          style: :bold,
          leading: 8
        },
        {
          size: font_manager.find_font_size(:channel),
          leading: 5
        },
        {
          size: font_manager.find_font_size(:channel),
          leading: 5
        },
        {
          size: font_manager.find_font_size(:channel),
          leading: 5,
          inline_format: true
        },
        {
          size: font_manager.find_font_size(:channel),
          leading: 5,
          inline_format: true
        }
      ]
      formatting_config[line_no]
    end

    def introduction usage, font_manager
      line_height = 1.45

      formatting_config = {
        :heading => {
          size: font_manager.find_font_size(:heading),
          style: :bold,
          leading: line_height * font_manager.find_font_size(:heading)
        },
        :default => {
          size: font_manager.find_font_size(:body),
          leading: 6,
          indent_paragraphs: 0
        }
      }

      formatting_config[usage]
    end

    def work_experience usage, font_manager
      line_height = 1.45

      formatting_config = {
        :heading => {
          size: font_manager.find_font_size(:heading),
          style: :bold,
          leading: line_height * font_manager.find_font_size(:heading)
        },
        :default => {
          size: font_manager.find_font_size(:body),
          leading: 6,
          indent_paragraphs: 0
        },
        :long_leading => {
          size: font_manager.find_font_size(:body),
          leading: 12,
          indent_paragraphs: 0
        }
      }

      formatting_config[usage]
    end

    def side_project usage, font_manager
      line_height = 1.45

      formatting_config = {
        :heading => {
          size: font_manager.find_font_size(:heading),
          style: :bold,
          leading: line_height * font_manager.find_font_size(:heading)
        },
        :project => {
          size: font_manager.find_font_size(:body),
          indent_paragraphs: 0
        },
        :default => {
          size: font_manager.find_font_size(:body),
          leading: 6,
          indent_paragraphs: 0
        }
      }

      formatting_config[usage]
    end

    def portfolio usage, font_manager
      line_height = 1.45

      formatting_config = {
        :heading => {
          size: font_manager.find_font_size(:heading),
          style: :bold,
          leading: line_height * font_manager.find_font_size(:heading)
        },
        :project => {
          size: font_manager.find_font_size(:body),
          indent_paragraphs: 0
        },
        :default => {
          size: font_manager.find_font_size(:body),
          leading: 6,
          indent_paragraphs: 0
        }
      }

      formatting_config[usage]
    end

    def education usage, font_manager, doc
      line_height = 1.45
      left_col_width = 180 # Adjust based on content and page layout needs
      right_col_start = left_col_width + 10 # Spacing between columns

      formatting_config = {
        :heading => {
          size: font_manager.find_font_size(:heading),
          style: :bold,
          leading: line_height * font_manager.find_font_size(:heading)
        },
        :left => {
          size: font_manager.find_font_size(:body),
          at: [0, y_position(doc)],
          width: left_col_width,
          align: :left
        },
        :right => {
          size: font_manager.find_font_size(:body),
          at: [right_col_start, y_position(doc)],
          width: bound_width(doc) - right_col_start,
          align: :left
        }
      }

      formatting_config[usage]
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
end
