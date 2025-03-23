require_relative '../../lib/mk_resume/pdf_typesetter'

describe MkResume::PdfTypesetter do
  RSpec.configure do |config|
    config.filter_run_when_matching(focus: true)
    config.example_status_persistence_file_path = 'spec/pass_fail_history'
  end

  SECTION_DATA_DIR = File.join(File.dirname(__FILE__), *%w[.. data src])
  context "요청할 전략 객체 목록을 찾을 수 있다" do
    typesetter = MkResume::PdfTypesetter.new

    it "전략 객체 목록을 가져올 수 있다" do
      typesetter.strategy_list.each {|strategy|
        expect(strategy).to match(/MkResume::.*TypesetStrategy/)
      }
    end
  end

  context "주어진 섹션 플레인 텍스트를 처리할 수 있는 전략 객체를 검색할 수 있다" do
    typesetter = MkResume::PdfTypesetter.new

    it "업무 경력 섹션" do
      src_path = File.join(SECTION_DATA_DIR, *%w[work_experience])

      expect(typesetter.find_strategy(File.read(src_path))).to eq(MkResume::WorkExpTypesetStrategy.name)
    end

    it "포트폴리오 섹션" do
      src_path = File.join(SECTION_DATA_DIR, *%w[portfolio])

      expect(typesetter.find_strategy(File.read(src_path))).to eq(MkResume::PortfolioTypesetStrategy.name)
    end

    it "사이드 프로젝트 섹션" do
      src_path = File.join(SECTION_DATA_DIR, *%w[side_project])

      expect(typesetter.find_strategy(File.read(src_path))).to eq(MkResume::SideProjTypesetStrategy.name)
    end

    it "목록 형식 섹션" do
      src_path = File.join(SECTION_DATA_DIR, *%w[list_section])

      expect(typesetter.find_strategy(File.read(src_path))).to eq(MkResume::ListTypesetStrategy.name)
    end

    it "2열 형식 섹션" do
      src_path = File.join(SECTION_DATA_DIR, *%w[two_columns_section])

      expect(typesetter.find_strategy(File.read(src_path))).to eq(MkResume::TwoColumnsTypesetStrategy.name)
    end

    it "일치하는 전략 객체가 없을 때" do
      expect(
        typesetter.validate_search_result([])
      ).to eq(MkResume::DefaultTypesetStrategy.name)
    end

    it "일치하는 전략 객체가 두 개 이상일 때" do
      expect {
        typesetter.validate_search_result(["WorkExpTypesetStrategy", "AnotherTypesetStrategy"])
      }.to raise_error(MkResume::TypesetStrategyFindError)
    end
  end

  context "주어진 섹션 플레인 텍스트를 조판할 수 있는 방법을 알 수 있다" do
    typesetter = MkResume::PdfTypesetter.new

    it "업무 경력 섹션" do
      src_path = File.join(SECTION_DATA_DIR, *%w[work_experience])

      expect(typesetter.handler(File.read(src_path)).lambda?).to eq(true)
    end

    it "포트폴리오 섹션" do
      src_path = File.join(SECTION_DATA_DIR, *%w[portfolio])

      expect(typesetter.handler(File.read(src_path)).lambda?).to eq(true)
    end

    it "사이드 프로젝트 섹션" do
      src_path = File.join(SECTION_DATA_DIR, *%w[side_project])

      expect(typesetter.handler(File.read(src_path)).lambda?).to eq(true)
    end

    it "목록 형식 섹션" do
      src_path = File.join(SECTION_DATA_DIR, *%w[introduction])

      expect(typesetter.handler(File.read(src_path)).lambda?).to eq(true)
    end

    it "2열 형식 섹션" do
      src_path = File.join(SECTION_DATA_DIR, *%w[education])

      expect(typesetter.handler(File.read(src_path)).lambda?).to eq(true)
    end

    it "일치하는 전략 객체가 없을 때" do
      src_path = File.join(SECTION_DATA_DIR, *%w[personal_info])

      expect(typesetter.handler(File.read(src_path)).lambda?).to eq(true)
    end
  end
end
