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
end

