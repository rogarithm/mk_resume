module MkResume
  class MarkdownParser
    # 마크다운 텍스트를 파싱하여 트리 구조로 반환
    #
    # @param text [String] 마크다운 형식의 텍스트
    # @return [Array<Hash>] 파싱된 노드 배열
    #   각 노드는 다음 구조를 가짐:
    #   {
    #     type: :heading | :list_item | :text,
    #     content: "텍스트 내용",
    #     level: 0~N (들여쓰기 레벨),
    #     children: [Node, ...]
    #   }
    def parse(text)
      lines = text.split("\n").reject { |l| l.strip.empty? }
      build_tree(lines)
    end

    private

    def build_tree(lines)
      nodes = []
      stack = [{ level: -1, children: nodes }]  # 루트 노드

      lines.each do |line|
        node = parse_line(line)

        # 현재 노드의 레벨보다 높거나 같은 레벨의 부모를 찾을 때까지 스택 pop
        while stack.last[:level] >= node[:level]
          stack.pop
        end

        # 현재 부모의 children에 추가
        parent = stack.last
        parent[:children] << node

        # 자식을 가질 수 있는 노드는 스택에 push
        stack.push(node)
      end

      nodes
    end

    def parse_line(line)
      level = calculate_indent_level(line)
      stripped = line.strip

      case stripped
      when /^#\s+(.+)$/  # 헤딩: # 제목
        create_node(:heading, $1, level)
      when /^-\s+(.+)$/  # 리스트 아이템: - 내용
        create_node(:list_item, $1, level)
      else  # 일반 텍스트
        create_node(:text, stripped, level)
      end
    end

    def create_node(type, content, level)
      {
        type: type,
        content: content,
        level: level,
        children: []
      }
    end

    def calculate_indent_level(line)
      # 1칸 공백 = 레벨 1
      line.match(/^(\s*)/)[1].length
    end
  end
end
