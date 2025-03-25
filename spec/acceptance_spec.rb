require_relative "../lib/mk_resume"

describe ResumePrinter do
  RSpec.configure do |config|
    config.filter_run_when_matching(focus: true)
    config.example_status_persistence_file_path = 'spec/pass_fail_history'
  end

  it "포맷 정보를 불러올 메서드명을 동적으로 결정할 수 있다" do
    unconfigured_section = :list_section
    resume_printer = ResumePrinter.new
    expect {
      resume_printer.print(%W[.. .. spec data src],
        [
          unconfigured_section, :introduction, :portfolio,
          :work_experience, :side_project, :education
        ]
      )
    }.to raise_error(
      MkResume::FormattingConfigNotExistsError,
      /#{unconfigured_section.to_s}/
    )
  end
end
