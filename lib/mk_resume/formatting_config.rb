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
  end
end
