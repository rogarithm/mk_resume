module MkResume
  class LayoutArranger
    DOC_MARGIN = {:top => 2.cm, :right => 3.05.cm, :bottom => 2.cm, :left => 3.05.cm}

    def find_margin_size(where)
      DOC_MARGIN[where]
    end

    def make_vertical_space(pdf_doc, point)
      pdf_doc.move_down point
    end

    alias_method :v_space, :make_vertical_space

    def draw_horizontal_rule(pdf_doc)
      pdf_doc.stroke_horizontal_rule
    end

    alias_method :h_rule, :draw_horizontal_rule
  end
end
