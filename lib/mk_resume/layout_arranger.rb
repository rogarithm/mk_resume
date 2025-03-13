module MkResume
  class LayoutArranger
    DOC_MARGIN = {:top => 2.cm, :right => 3.05.cm, :bottom => 2.cm, :left => 3.05.cm}

    def doc_margins
      DOC_MARGIN.reduce([]) {|margins, (_, v)| margins << v}
    end

    def make_vertical_space(pdf_doc, point)
      pdf_doc.move_down point
    end

    alias_method :v_space, :make_vertical_space
  end
end
