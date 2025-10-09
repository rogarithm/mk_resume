module MkResume
  class NodeFormatter
    BULLET_POINTS = {
      0 => "",
      1 => "   ",
      2 => "     ",
      3 => "       "
    }

    def format_list_item(node, style)
      {
        method: :write_indented_text,
        indent: bullet_for_level(node[:level]),
        text: "•  " + node[:content],
        style: style
      }
    end

    def format_text(node, style)
      {
        method: :write_text,
        text: node[:content],
        style: style
      }
    end

    private

    def bullet_for_level(level)
      BULLET_POINTS[level] || ("  " * (level - 1)) + "   "
    end
  end
end
