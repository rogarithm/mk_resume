module MkResume
  class PdfTypesetter
    def strategy_list
      [
        WorkExpTypesetStrategy.name,
        PortfolioTypesetStrategy.name,
        ListTypesetStrategy.name,
        TwoColumnsTypesetStrategy.name
      ]
    end

    def find_strategy section_txt
      matching_strategy = self.strategy_list.reduce([]) {|result, strategy_nm|
        strategy = Object::const_get(strategy_nm).new
        result << strategy_nm if strategy.can_handle?(section_txt)
        result
      }

      validate_search_result matching_strategy

      matching_strategy.first
    end

    def validate_search_result matching_strategy
      if matching_strategy.nil?
        return DefaultTypesetStrategy.name
      end
      if matching_strategy.size > 1
        raise TypesetStrategyFindError.new("found more than one typeset strategy to handle given section text!")
      end
    end
  end

  class TypesetStrategyFindError < StandardError; end

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

  class PortfolioTypesetStrategy
    include TypesetStrategy

    def can_handle? section_txt
      section_txt.split("\n").first.match(/^portfolio_nm:.*$/)
    end
  end

  class ListTypesetStrategy
    include TypesetStrategy

    def can_handle? section_txt
      lines = section_txt.split("\n")
      lines.size == lines.filter {|l| l.match(/^\s*-\s+.*$/)}.size
    end
  end

  class TwoColumnsTypesetStrategy
    include TypesetStrategy

    def can_handle? section_txt
      lines = section_txt.split("\n")
      lines.size == lines.filter { |l| l.match(/^.*\s*\|\s*.*$/) }.size
    end
  end

  class DefaultTypesetStrategy
    include TypesetStrategy

    def can_handle? section_txt
      true
    end
  end
end
