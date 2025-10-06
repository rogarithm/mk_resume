require_relative '../../lib/mk_resume/pdf_typesetter'

describe MkResume::PdfTypesetter do
  RSpec.configure do |config|
    config.filter_run_when_matching(focus: true)
    config.example_status_persistence_file_path = 'spec/pass_fail_history'
  end

  SECTION_DATA_DIR = File.join(File.dirname(__FILE__), *%w[.. data src])
  it "요청할 전략 객체 목록을 가져올 수 있다" do
    typesetter = MkResume::PdfTypesetter.new

    typesetter.strategy_list.each {|strategy|
      expect(strategy).to match(/MkResume::.*TypesetStrategy/)
    }
  end

  it "주어진 섹션 플레인 텍스트를 처리할 수 있는 전략 객체를 검색할 수 있다" do
    typesetter = MkResume::PdfTypesetter.new

    %w[work_experience portfolio side_project introduction education personal_info].each do |section|
      src_path = File.join(SECTION_DATA_DIR, *%W[#{section}])

      expect(typesetter.find_strategy(File.read(src_path))).to eq(MkResume::MarkdownTypesetStrategy.name)
    end
  end

  it "일치하는 전략 객체가 두 개 이상일 경우 예외 처리한다" do
    typesetter = MkResume::PdfTypesetter.new

    expect {
      typesetter.validate_search_result(["MarkdownTypesetStrategy", "AnotherTypesetStrategy"])
    }.to raise_error(MkResume::TypesetStrategyFindError)
  end

  it "주어진 섹션 플레인 텍스트를 조판할 수 있는 방법을 알 수 있다" do
    typesetter = MkResume::PdfTypesetter.new

    %w[work_experience portfolio side_project introduction education personal_info].each do |section|
      src_path = File.join(SECTION_DATA_DIR, *%W[#{section}])

      expect(typesetter.handler(File.read(src_path)).lambda?).to eq(true)
    end
  end
end
