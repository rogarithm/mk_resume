module MkResume
  class PdfTypesetter
    def strategy_list
      [
        MarkdownTypesetStrategy.name
      ]
    end

    def handler section_txt
      strategy_nm = find_strategy(section_txt)
      strategy = Object::const_get(strategy_nm).new
      strategy.handler
    end

    def find_strategy section_txt
      matching_strategy = self.strategy_list.reduce([]) {|result, strategy_nm|
        strategy = Object::const_get(strategy_nm).new
        result << strategy_nm if strategy.can_handle?(section_txt)
        result
      }

      validate_search_result(matching_strategy)
    end

    def validate_search_result matching_strategy
      if matching_strategy.size == 0
        return DefaultTypesetStrategy.name
      end
      if matching_strategy.size > 1
        raise TypesetStrategyFindError.new("found more than one typeset strategy to handle given section text!")
      end
      matching_strategy.first
    end
  end

  class TypesetStrategyFindError < StandardError; end

  module TypesetStrategy
    def can_handle? section_txt
      raise "Not implemented"
    end

    def handler
      raise "Not implemented"
    end
  end

  class DefaultTypesetStrategy
    include TypesetStrategy

    def can_handle? section_txt
      true
    end

    def handler
      lambda {|section_nm, section_txt, opts|
        section_txt.split("\n")[0..4].each.with_index do |text, idx|
          opts[:doc_writer].write_text(
            opts[:doc],
            text,
            opts[:formatting_config].send(section_nm, idx)
          )
        end
        opts[:layout_arranger].v_space(opts[:doc], 14.5)
      }
    end
  end

  class MarkdownTypesetStrategy
    include TypesetStrategy

    def can_handle? section_txt
      section_txt.split("\n").first.match(/^markdown.*$/)
    end

    def handler
      lambda {|section_nm, section_txt, opts|
        require_relative './markdown_parser'
        require_relative './node_formatter'

        # "markdown:" 마커 제거
        content = section_txt.split("\n")[1..-1].join("\n")

        # 마크다운 파싱
        parser = MkResume::MarkdownParser.new
        nodes = parser.parse(content)

        # 섹션 헤딩 렌더링 (섹션명 자동 생성)
        opts[:doc_writer].write_heading(
          opts[:doc],
          section_nm,
          opts[:formatting_config].send("markdown", :heading)
        )

        # 문서 첫 노드의 h 레벨 기준으로 그룹화
        groups = group_by_h(nodes)

        # 각 그룹 렌더링 (그룹 사이에 큰 간격)
        groups.each_with_index do |group, idx|
          render_nodes(group, "markdown", opts)
          opts[:layout_arranger].v_space(opts[:doc], 10) if idx < groups.size - 1
        end

        opts[:layout_arranger].v_space(opts[:doc], 10)
      }
    end

    private

    def group_by_h(nodes)
      return [nodes] if nodes.empty?

      # 첫 번째 헤딩 타입을 그룹 구분 기준으로 사용
      separator_type = nodes.find { |n| heading?(n) }&.fetch(:type)
      return [nodes] unless separator_type  # 헤딩이 없으면 전체를 하나의 그룹으로

      groups = []
      group_now = []

      nodes.each do |node|
        if node[:type] == separator_type && !group_now.empty?
          groups << group_now
          group_now = [node]
        else
          group_now << node
        end
      end

      groups << group_now if not group_now.empty?
      groups
    end

    def heading?(node)
      node[:type].to_s.match?(/^h[1-6]$/)
    end

    def render_nodes(nodes, section_nm, opts, level = 0)
      formatter = NodeFormatter.new

      nodes.each do |node|
        # 동적으로 노드 타입에서 스타일 키 추출
        style_key = node[:type]

        # 스타일 가져오기 (nil 체크)
        style = opts[:formatting_config].send("markdown", style_key)
        if style.nil?
          warn "WARNING: No style for section=#{section_nm}, key=#{style_key}, node_type=#{node[:type]}"
          style = opts[:formatting_config].send("markdown", :default)
        end

        case node[:type]
        when /h\d{1}/
          opts[:doc_writer].write_text(
            opts[:doc],
            node[:content],
            style
          )

        when :bold
          opts[:doc_writer].write_text(
            opts[:doc],
            node[:content],
            style
          )

        when :list_item
          params = formatter.format_list_item(node, style)
          opts[:doc_writer].write_indented_text(
            opts[:doc],
            params[:indent],
            params[:text],
            params[:style]
          )

        when :text
          text_style = opts[:formatting_config].send(section_nm, :default)
          if text_style.nil?
            warn "WARNING: No default style for section=#{section_nm}"
            text_style = {}
          end
          opts[:doc_writer].write_text(
            opts[:doc],
            node[:content],
            text_style
          )
        end

        # children 재귀 렌더링
        render_nodes(node[:children], section_nm, opts, level + 1) unless node[:children].empty?
      end
    end
  end
end
