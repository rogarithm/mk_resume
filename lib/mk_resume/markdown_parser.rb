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

    def build_tree(lines)
      nodes = []
      stack = [{ level: -1, children: nodes }]  # 루트 노드. nodes는 참조로 공유됨

      lines.each do |line|
        node = parse_line(line)

        # 현재 노드보다 레벨이 높거나 같은 노드들을 스택에서 제거
        # (더 이상 자식을 받을 수 없는 노드들)
        while stack.last[:level] >= node[:level]
          stack.pop
        end

        # 스택의 마지막 노드가 현재 노드의 부모
        parent = stack.last
        parent[:children] << node

        # 현재 노드를 스택에 추가 (이후 줄들의 잠재적 부모로 등록)
        stack.push(node)
      end

      nodes  # 루트의 children (참조를 통해 이미 모든 자식이 채워져 있음)
    end

    private

    def parse_line(line)
      lvl = indent_lvl(line)
      stripped = line.strip

      case stripped
      when /^#\s+(.+)$/  # 헤딩: # 제목
        create_node(:heading, $1, lvl)
      when /^-\s+(.+)$/  # 리스트 아이템: - 내용
        create_node(:list_item, $1, lvl)
      else  # 일반 텍스트
        create_node(:text, stripped, lvl)
      end
    end

    def create_node(type, content, lvl)
      {
        type: type,
        content: content,
        level: lvl,
        children: []
      }
    end

    def indent_lvl(line)
      # 1칸 공백 = 레벨 1
      line.match(/^(\s*)/)[1].length
    end
  end
end
