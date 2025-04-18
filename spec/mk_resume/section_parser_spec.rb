require_relative "../../lib/mk_resume/section_parser"

describe MkResume::SectionParser do
  RSpec.configure do |config|
    config.filter_run_when_matching(focus: true)
    config.example_status_persistence_file_path = 'spec/pass_fail_history'
  end

  TEST_DATA_DIR = File.join(File.dirname(__FILE__), *%w[.. data])

  before(:each) do
    @parser = MkResume::SectionParser.new
  end

  context "키워드를 기준으로 시맨틱 모델 하나를 만들 영역을 나눌 수 있다" do
    it "키워드명이 company_nm일 때" do
      src_path = File.join(TEST_DATA_DIR, *%w[two_company_nm])

      expected = [
        ["company_nm: c1"],
        ["company_nm: c2"]
      ]

      expect(@parser.segments_by_keyword(File.read(src_path))).to eq(expected)
    end

    it "키워드명이 side_proj_nm일 때" do
      src_path = File.join(TEST_DATA_DIR, *%w[two_side_proj_nm])

      expected = [
        ["side_proj_nm: s1"],
        ["side_proj_nm: s2"]
      ]

      expect(@parser.segments_by_keyword(File.read(src_path), "side_proj_nm")).to eq(expected)
    end
  end

  context "업무 프로젝트에 대한 시맨틱 모델을 만들 수 있다" do
    it "업무 하나에 대한 상세 내용" do
      src_path = File.join(TEST_DATA_DIR, *%w[one_task])
      basic_proj = MkResume::Model::BasicProjectMaker.new

      expected = {
        "p1" => [
          {"t1" => ["d1", "d2", "d3"]}
        ]
      }

      expect(basic_proj.make(File.read(src_path))).to eq(expected)
    end

    it "업무 둘에 대한 상세 내용" do
      src_path = File.join(TEST_DATA_DIR, *%w[two_task])
      basic_proj = MkResume::Model::BasicProjectMaker.new

      expected = {
        "p1" => [
          { "t1" => ["d1", "d2", "d3"] },
          { "t2" => ["d4", "d5", "d6"] },
        ]
      }

      expect(basic_proj.make(File.read(src_path))).to eq(expected)
    end

    it "두 프로젝트, 프로젝트별 업무가 하나" do
      src_path = File.join(TEST_DATA_DIR, *%w[one_task_each])
      basic_proj = MkResume::Model::BasicProjectMaker.new

      expected = {
        "p1" => [
          { "t1" => ["d1", "d2", "d3"] }
        ],
        "p2" => [
          { "t1" => ["d1", "d2", "d3"] }
        ]
      }

      expect(basic_proj.make(File.read(src_path))).to eq(expected)
    end

    it "두 프로젝트, 프로젝트당 업무가 여러 개" do
      src_path = File.join(TEST_DATA_DIR, *%w[two_tasks_each])
      basic_proj = MkResume::Model::BasicProjectMaker.new

      expected = {
        "p1" => [
          { "t1" => ["d1", "d2", "d3"] },
          { "t2" => ["d4", "d5", "d6"] }
        ],
        "p2" => [
          { "t1" => ["d1", "d2", "d3"] },
          { "t2" => ["d4", "d5", "d6"] }
        ]
      }

      expect(basic_proj.make(File.read(src_path))).to eq(expected)
    end
  end

  context "포트폴리오 프로젝트에 대한 시맨틱 모델을 만들 수 있다" do
    it "업무 상세 내용이 없고, 문제 해결 상세 내용이 있다" do
      src_path = File.join(TEST_DATA_DIR, *%w[portfolio_proj])
      portfolio_proj = MkResume::Model::PortfolioProjectMaker.new

      expected = {
        :tasks => ["x", "y"],
        :trouble_shooting => [
          {"z" => ["z1" ,"z2" ,"z3"]}
        ]
      }

      expect(portfolio_proj.make(File.read(src_path))).to eq(expected)
    end
  end

  context "프로젝트 정보와 회사 관련 정보를 함께 시맨틱 모델로 만들 수 있다" do

    it "시맨틱 모델에 넣을 키워드를 메서드 인자로 쓸 수 있다" do
      kw_list = [:company_nm, :skill_set]
      lines = ["company_nm: xx", "nothing: yy", "skill_set: zz"]
      obj = {}
      # 주어진 키워드로 시작하는 줄만 필터링한다
      matching_lines = lines.filter {|l|
        kw_list.any? {|kw|
          l =~ /^\s*(#{kw.to_s})/
        }
      }
      expect(matching_lines).to eq(["company_nm: xx", "skill_set: zz"])

      # 필터링한 줄을 객체에 저장한다
      matching_lines.each {|l|
        k_v = l.split(":").map(&:strip)
        obj[k_v[0].to_sym] = k_v[1]
      }
      expect(obj).to eq({:company_nm => "xx", :skill_set => "zz"})

      # 나머지 줄을 따로 모은다
      expect(lines - matching_lines).to eq(["nothing: yy"])
    end

    it ": 문자가 여러 번 나오더라도 키값 구분을 제대로 할 수 있다" do
      has_one_colon = "proj_link: x"
      split1 = has_one_colon.split(":", 2)
      expect(split1).to eq(["proj_link", " x"])

      has_multiple_colons = "proj_link: x:y"
      split2 = has_multiple_colons.split(":", 2)
      expect(split2).to eq(["proj_link", " x:y"])
    end

    it "회사명 하나" do
      src_path = File.join(TEST_DATA_DIR, *%w[one_company_nm])

      expected = {
        :company_nm => "c1"
      }

      expect(@parser.make_obj(File.read(src_path))).to eq(expected)
    end

    it "한 회사에서의 경력 사항" do
      src_path = File.join(TEST_DATA_DIR, *%w[one_work_exp])

      expected = {
        :company_nm => "c1 (f ~ t)",
        :project => {
          "p1" => [
            { "t1" => ["d1", "d2", "d3"] },
            { "t2" => ["d4", "d5", "d6"] }
          ]
        }
      }

      expect(@parser.make_obj(File.read(src_path))).to eq(expected)
    end

    it "회사 경력 사항 중 업무명이 명시되지 않았을 경우를 처리" do
      src_path = File.join(TEST_DATA_DIR, *%w[no_task_desc])

      expected = {
        :project => {
          "p1" => [
            { :EMPTY_TASK_DESC => ["d1", "d2", "d3"] },
          ]
        }
      }

      expect(@parser.make_obj(File.read(src_path))).to eq(expected)
    end

    it "실제 데이터로 테스트한다" do
      src_path = File.join(TEST_DATA_DIR, *%w[doit_work_exp])

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
              :EMPTY_TASK_DESC => [
                "사내 개발 인력 증가로 개별 작업한 프로젝트 소스 코드의 통합 문제가 우려되어 버전 관리를 도입",
                "GitLab 서버 설치, 유지 보수 담당 및 사내 팀원에게 Git을 통한 형상 관리 세미나 진행",
                "여러 인원이 참여하는 프로젝트에서 소스 코드 통합 문제 해결에 기여"
              ]
            }
          ]
        }
      }

      expect(@parser.make_obj(File.read(src_path))).to eq(expected)
    end
  end
end
