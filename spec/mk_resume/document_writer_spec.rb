require_relative "../../lib/mk_resume/document_writer"

describe MkResume::DocumentWriter do
  RSpec.configure do |config|
    config.filter_run_when_matching(focus: true)
    config.example_status_persistence_file_path = 'spec/pass_fail_history'
  end

  it "각 섹션 내용을 적은 파일을 읽어올 수 있다" do
    dw = MkResume::DocumentWriter.new
    dw.read_sections(%W[.. .. spec  data src])
    expect(dw.sections.keys.size).not_to be(0)
  end

  context "헤딩 생성 시 자동으로 포맷팅한다" do
    dw = MkResume::DocumentWriter.new

    it "_로 구분되지 않은 경우 헤딩용 제목을 섹션 파일명으로부터 만들 수 있다" do
      expect(dw.capitalize(:portfolio)).to eq("Portfolio")
    end

    it "_로 구분된 경우 헤딩용 제목을 섹션 파일명으로부터 만들 수 있다" do
      expect(dw.capitalize(:side_project)).to eq("Side Project")
    end
  end
end

