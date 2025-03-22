module MkResume
  class PdfTypesetter
    def strategy_list
      [WorkExpTypesetStrategy.name]
    end

    def find_strategy section_txt
      self.strategy_list.reduce([]) { |result, strategy_nm|
        strategy = Object::const_get(strategy_nm).new
        if strategy.can_handle? section_txt
          result << strategy_nm
        end
      }.first
    end
  end

  module TypesetStrategy
    def can_handle? section_txt
      raise "Not implemented"
    end
  end

  class WorkExpTypesetStrategy
    include TypesetStrategy

    def can_handle? section_txt
      section_txt.split("\n").first.match(/^company_nm:.*$/)
    end
  end
end
