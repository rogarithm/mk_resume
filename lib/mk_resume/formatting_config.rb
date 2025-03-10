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
  end
end
