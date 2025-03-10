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
