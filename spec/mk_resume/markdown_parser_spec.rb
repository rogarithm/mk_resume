require_relative "../../lib/mk_resume/markdown_parser"

describe MkResume::MarkdownParser do
  RSpec.configure do |config|
    config.filter_run_when_matching(focus: true)
    config.example_status_persistence_file_path = 'spec/pass_fail_history'
  end

  before(:each) do
    @parser = MkResume::MarkdownParser.new
  end

  def node(*params)
    type, content, level, children = params
    {
      type: type,
      content: content,
      level: level || 0,
      children: children ? mk_nodes(children) : []
    }
  end

  def mk_nodes(nodes)
    nodes.map do |params|
      node(*params)
    end
  end

  context "마크다운 요소를 파싱한다" do
    it "헤딩" do
      text = "# 제목"
      result = @parser.parse(text)

      expect(result).to eq(mk_nodes [[:heading, "제목"]])
    end

    it "리스트 아이템" do
      text = "- 첫 번째 아이템"
      result = @parser.parse(text)

      expect(result).to eq(mk_nodes [[:list_item, "첫 번째 아이템", 0]])
    end

    it "일반 텍스트" do
      text = "일반 텍스트"
      result = @parser.parse(text)

      expect(result).to eq(mk_nodes [[:text, "일반 텍스트", 0]])
    end
  end

  context "들여쓰기 레벨을 계산한다" do
    it "들여쓰기 없음" do
      text = "- 아이템"
      result = @parser.parse(text)

      expect(result[0][:level]).to eq(0)
    end

    it "1칸 들여쓰기 (레벨 1)" do
      text = " - 아이템"
      result = @parser.parse(text)

      expect(result[0][:level]).to eq(1)
    end

    it "2칸 들여쓰기 (레벨 2)" do
      text = "  - 아이템"
      result = @parser.parse(text)

      expect(result[0][:level]).to eq(2)
    end
  end

  context "중첩 구조를 파싱한다" do
    it "2단 리스트 구조" do
      text = <<~MD
        - 첫 번째
         - 중첩된 아이템
      MD

      result = @parser.parse(text)

      expect(result).to eq(mk_nodes [[:list_item, "첫 번째", 0,
                                      [[:list_item, "중첩된 아이템", 1]]
                                     ]])
    end

    it "3단 리스트 구조" do
      text = <<~MD
        - 레벨 0
         - 레벨 1
          - 레벨 2
      MD

      result = @parser.parse(text)

      expect(result).to eq(mk_nodes [[:list_item, "레벨 0", 0,
                                      [[:list_item, "레벨 1", 1,
                                        [[:list_item, "레벨 2", 2]]
                                       ]]
                                     ]])
    end

    it "같은 레벨의 여러 아이템" do
      text = <<~MD
        - 첫 번째
        - 두 번째
        - 세 번째
      MD

      result = @parser.parse(text)

      expect(result).to eq(mk_nodes [[:list_item, "첫 번째", 0],
                                     [:list_item, "두 번째", 0],
                                     [:list_item, "세 번째", 0]])
    end
  end

  context "복잡한 중첩 구조를 처리한다" do
    it "여러 부모 아래 여러 자식" do
      text = <<~MD
        - 첫 번째 부모
         - 자식 1-1
         - 자식 1-2
        - 두 번째 부모
         - 자식 2-1
      MD

      result = @parser.parse(text)

      expect(result).to eq(mk_nodes [[:list_item, "첫 번째 부모", 0,
                                      [[:list_item, "자식 1-1", 1],
                                       [:list_item, "자식 1-2", 1]]
                                     ],
                                     [:list_item, "두 번째 부모", 0,
                                      [[:list_item, "자식 2-1", 1]]
                                     ]])
    end

    it "헤딩과 리스트 혼합" do
      text = <<~MD
        # 섹션 제목
        - 첫 번째 아이템
        - 두 번째 아이템
      MD

      result = @parser.parse(text)

      expect(result).to eq(mk_nodes [[:heading, "섹션 제목", 0],
                                     [:list_item, "첫 번째 아이템", 0],
                                     [:list_item, "두 번째 아이템", 0]
                                    ])
    end
  end

  context "빈 줄을 무시한다" do
    it "빈 줄이 포함된 텍스트" do
      text = <<~MD
        - 첫 번째

        - 두 번째

      MD

      result = @parser.parse(text)

      expect(result).to eq(mk_nodes [[:list_item, "첫 번째", 0],
                                     [:list_item, "두 번째", 0]
                                    ])
    end
  end
end
