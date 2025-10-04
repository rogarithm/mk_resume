require_relative "../../lib/mk_resume/markdown_parser"

describe MkResume::MarkdownParser do
  RSpec.configure do |config|
    config.filter_run_when_matching(focus: true)
    config.example_status_persistence_file_path = 'spec/pass_fail_history'
  end

  before(:each) do
    @parser = MkResume::MarkdownParser.new
  end

  context "마크다운 요소를 파싱한다" do
    it "헤딩" do
      text = "# 제목"
      result = @parser.parse(text)

      expect(result.size).to eq(1)
      expect(result[0][:type]).to eq(:heading)
      expect(result[0][:content]).to eq("제목")
      expect(result[0][:level]).to eq(0)
    end

    it "리스트 아이템" do
      text = "- 첫 번째 아이템"
      result = @parser.parse(text)

      expect(result.size).to eq(1)
      expect(result[0][:type]).to eq(:list_item)
      expect(result[0][:content]).to eq("첫 번째 아이템")
      expect(result[0][:level]).to eq(0)
    end

    it "일반 텍스트" do
      text = "일반 텍스트"
      result = @parser.parse(text)

      expect(result.size).to eq(1)
      expect(result[0][:type]).to eq(:text)
      expect(result[0][:content]).to eq("일반 텍스트")
      expect(result[0][:level]).to eq(0)
    end
  end

  context "들여쓰기 레벨을 계산한다" do
    it "들여쓰기 없음" do
      text = "- 아이템"
      result = @parser.parse(text)

      expect(result[0][:level]).to eq(0)
    end

    it "2칸 들여쓰기 (레벨 1)" do
      text = "  - 아이템"
      result = @parser.parse(text)

      expect(result[0][:level]).to eq(1)
    end

    it "4칸 들여쓰기 (레벨 2)" do
      text = "    - 아이템"
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

      expect(result.size).to eq(1)
      expect(result[0][:content]).to eq("첫 번째")
      expect(result[0][:children].size).to eq(1)
      expect(result[0][:children][0][:content]).to eq("중첩된 아이템")
    end

    it "3단 리스트 구조" do
      text = <<~MD
        - 레벨 0
          - 레벨 1
            - 레벨 2
      MD

      result = @parser.parse(text)

      expect(result.size).to eq(1)
      expect(result[0][:content]).to eq("레벨 0")
      expect(result[0][:children].size).to eq(1)
      expect(result[0][:children][0][:content]).to eq("레벨 1")
      expect(result[0][:children][0][:children].size).to eq(1)
      expect(result[0][:children][0][:children][0][:content]).to eq("레벨 2")
    end

    it "같은 레벨의 여러 아이템" do
      text = <<~MD
        - 첫 번째
        - 두 번째
        - 세 번째
      MD

      result = @parser.parse(text)

      expect(result.size).to eq(3)
      expect(result[0][:content]).to eq("첫 번째")
      expect(result[1][:content]).to eq("두 번째")
      expect(result[2][:content]).to eq("세 번째")
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

      expect(result.size).to eq(2)
      expect(result[0][:children].size).to eq(2)
      expect(result[0][:children][0][:content]).to eq("자식 1-1")
      expect(result[0][:children][1][:content]).to eq("자식 1-2")
      expect(result[1][:children].size).to eq(1)
      expect(result[1][:children][0][:content]).to eq("자식 2-1")
    end

    it "헤딩과 리스트 혼합" do
      text = <<~MD
        # 섹션 제목
        - 첫 번째 아이템
        - 두 번째 아이템
      MD

      result = @parser.parse(text)

      expect(result.size).to eq(3)
      expect(result[0][:type]).to eq(:heading)
      expect(result[0][:children].size).to eq(0)
      expect(result[1][:type]).to eq(:list_item)
      expect(result[2][:type]).to eq(:list_item)
    end
  end

  context "빈 줄을 무시한다" do
    it "빈 줄이 포함된 텍스트" do
      text = <<~MD
        - 첫 번째

        - 두 번째

      MD

      result = @parser.parse(text)

      expect(result.size).to eq(2)
      expect(result[0][:content]).to eq("첫 번째")
      expect(result[1][:content]).to eq("두 번째")
    end
  end
end
