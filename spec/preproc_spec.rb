require_relative "../lib/preproc"

describe Preproc do
  RSpec.configure do |config|
    config.filter_run_when_matching(focus: true)
    config.example_status_persistence_file_path = 'spec/pass_fail_history'
  end

  TEST_DATA_DIR = File.join(File.dirname(__FILE__), *%w[data])

  before(:each) do
    @pp = Preproc.new
  end

  it "여러 회사명, 일한 기간을 파싱할 수 있다" do
    src_path_sp = File.join(TEST_DATA_DIR, *%w[company_2])

    expected = [
      ["company_nm: c1", ""],
      ["company_nm: c2"]
    ]

    expect(@pp.split_by_company(File.read(src_path_sp))).to eq(expected)
  end

  it "회사명, 일한 기간을 파싱할 수 있다" do
    src_path_sp = File.join(TEST_DATA_DIR, *%w[company_1])

    expected = {
      :company_nm => "c1"
    }

    expect(@pp.group_by_company(File.read(src_path_sp))).to eq(expected)
  end

  it "한 일에 대해 작성한 내용을 모을 수 있다" do
    src_path_sp = File.join(TEST_DATA_DIR, *%w[solve_1])

    expected = {
      "s" => [
        {"w" => ["d1", "d2", "d3"]}
      ]
    }

    expect(@pp.group_project(File.read(src_path_sp))).to eq(expected)
  end

  it "한 일에 대해 작성한 여러 내용을 모을 수 있다" do
    src_path_sp = File.join(TEST_DATA_DIR, *%w[solve_2])

    expected = {
      "s" => [
        { "w" => ["d1", "d2", "d3"] },
        { "w2" => ["d4", "d5", "d6"] },
      ]
    }

    expect(@pp.group_project(File.read(src_path_sp))).to eq(expected)
  end

  it "여러 일에 대해 작성한 내용을 모을 수 있다" do
    src_path_sp = File.join(TEST_DATA_DIR, *%w[solves_1])

    expected = {
      "s" => [
        { "w" => ["d1", "d2", "d3"] }
      ],
      "s2" => [
        { "w" => ["d1", "d2", "d3"] }
      ]
    }

    expect(@pp.group_project(File.read(src_path_sp))).to eq(expected)
  end

  it "여러 일에 대해 작성한 여러 내용을 모을 수 있다" do
    src_path_sp = File.join(TEST_DATA_DIR, *%w[solves_2])

    expected = {
      "s" => [
        { "w" => ["d1", "d2", "d3"] },
        { "w2" => ["d4", "d5", "d6"] }
      ],
      "s2" => [
        { "w" => ["d1", "d2", "d3"] },
        { "w3" => ["d4", "d5", "d6"] }
      ]
    }

    expect(@pp.group_project(File.read(src_path_sp))).to eq(expected)
  end

  it "회사명, 일한 기간, 한 일을 파싱할 수 있다" do
    src_path_sp = File.join(TEST_DATA_DIR, *%w[company_with_solve_1])

    expected = {
      :company_nm => "c1 (f ~ t)",
      :project => {
        "s" => [
          { "w" => ["d1", "d2", "d3"] }
        ]
      }
    }

    expect(@pp.group_by_company(File.read(src_path_sp))).to eq(expected)
  end

  it "회사명, 일한 기간, 한 일을 파싱할 수 있다" do
    src_path_sp = File.join(TEST_DATA_DIR, *%w[company_with_solve_1])

    expected = {
      :company_nm => "c1 (f ~ t)",
      :project => {
        "s" => [
          { "w" => ["d1", "d2", "d3"] }
        ]
      }
    }

    expect(@pp.group_by_company(File.read(src_path_sp))).to eq(expected)
  end

  it "회사명, 일한 기간, 한 일 여러 개를 파싱할 수 있다" do
    src_path_sp = File.join(TEST_DATA_DIR, *%w[company_with_solve_2])

    expected = {
      :company_nm => "c1 (f ~ t)",
      :project => {
        "s" => [
          { "w" => ["d1", "d2", "d3"] },
          { "w2" => ["d4", "d5", "d6"] }
        ]
      }
    }

    expect(@pp.group_by_company(File.read(src_path_sp))).to eq(expected)
  end

  it "what이 없는 경우 기본값을 설정한다" do
    src_path_sp = File.join(TEST_DATA_DIR, *%w[no_what])

    expected = {
      :project => {
        "s" => [
          { :EMPTY_WHAT => ["d1", "d2", "d3"] },
        ]
      }
    }

    expect(@pp.group_by_company(File.read(src_path_sp))).to eq(expected)
  end

  it "actual" do
    src_path_sp = File.join(TEST_DATA_DIR, *%w[actual])

    expected = {
      :company_nm => "(주) 두잇 (2021.05 ~ 2022.05)",
      :project => {
        "건축 분야 알고리즘 기반 솔루션 개발 참여" => [
          {
            "트레일러 3D 모델을 보여주는 혼합현실 애플리케이션 개발 (C#, Unity, MRTK)" => [
              "수치값으로만 확인할 수 있었던 알고리즘 연산 결과를 3D 형태로 시각화해 부재 정보를 편하게 확인",
              "기존에 Unity 기반 2D 방식으로 구현되었으나, 시각적 제한을 개선하기 위해 혼합현실 기술을 도입",
              "사용자 편의성을 고려해 렌더링되는 트레일러의 위치와 조작 방식을 개선하고, 작업자가 현장에서 실제 트레일러와 3D 모델을 비교해볼 수 있도록 3D 모델 확대 기능을 구현"
            ]
          },
          {
            "캐드 소프트웨어 플러그인 개발 (C#, Revit API)" => [
              "알고리즘 연산에 필요한 입력값을 캐드 프로그램에서 입력하고 추출해 쓸 수 있도록 도와주는 플러그인",
              "캐드 외부에서 부재의 3D 모델을 활용할 수 있도록 건축 부재의 3D 모델링 정보 추출 기능을 구현",
              "기존 건축 설계 과정(설계도 제작) 중에 알고리즘 데이터 입력을 가능하도록 해 사용성을 개선"
            ]
          }
        ]
      }
    }

    expect(@pp.group_by_company(File.read(src_path_sp))).to eq(expected)
  end

  it "real actual" do
    src_path_sp = File.join(TEST_DATA_DIR, *%w[real_actual])

    expected = {
      :company_nm => "(주) 두잇 (2021.05 ~ 2022.05)",
      :project => {
        "건축 분야 알고리즘 기반 솔루션 개발 참여" => [
          {
            "트레일러 3D 모델을 보여주는 혼합현실 애플리케이션 개발 (C#, Unity, MRTK)" => [
              "수치값으로만 확인할 수 있었던 알고리즘 연산 결과를 3D 형태로 시각화해 부재 정보를 편하게 확인",
              "기존에 Unity 기반 2D 방식으로 구현되었으나, 시각적 제한을 개선하기 위해 혼합현실 기술을 도입",
              "사용자 편의성을 고려해 렌더링되는 트레일러의 위치와 조작 방식을 개선하고, 작업자가 현장에서 실제 트레일러와 3D 모델을 비교해볼 수 있도록 3D 모델 확대 기능을 구현"
            ]
          },
          {
            "캐드 소프트웨어 플러그인 개발 (C#, Revit API)" => [
              "알고리즘 연산에 필요한 입력값을 캐드 프로그램에서 입력하고 추출해 쓸 수 있도록 도와주는 플러그인",
              "캐드 외부에서 부재의 3D 모델을 활용할 수 있도록 건축 부재의 3D 모델링 정보 추출 기능을 구현",
              "기존 건축 설계 과정(설계도 제작) 중에 알고리즘 데이터 입력을 가능하도록 해 사용성을 개선"
            ]
          }
        ],
        "사내 버전 관리 문화 도입" => [
          {
            :EMPTY_WHAT => [
              "사내 개발 인력 증가로 개별 작업한 프로젝트 소스 코드의 통합 문제가 우려되어 버전 관리를 도입",
              "GitLab 서버 설치, 유지 보수 담당 및 사내 팀원에게 Git을 통한 형상 관리 세미나 진행",
              "여러 인원이 참여하는 프로젝트에서 소스 코드 통합 문제 해결에 기여"
            ]
          }
        ]
      }
    }

    expect(@pp.group_by_company(File.read(src_path_sp))).to eq(expected)
  end
end