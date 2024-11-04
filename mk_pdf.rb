require 'prawn'
require 'prawn/measurement_extensions'

# 플레인 텍스트 형식으로 적은 이력서를 pdf로 변환하기 위한 스크립트

def load_font
  Prawn::Font::AFM.hide_m17n_warning = true
  font_families.update(
    "NotoSans" => {
      normal: "./fonts/NotoSansKR-Regular.ttf",
      bold: "./fonts/NotoSansKR-Bold.ttf"
    }
  )
  font "NotoSans"
end

def draw_horizontal_line
  stroke_horizontal_rule
  move_down 9.5
end

def space_after_list_item
  move_down 2
end

def space_after_paragraph
  move_down 14.5
end

def draw_heading heading, font_size
  draw_horizontal_line
  line_height = 1.45
  text(
    heading[:text],
    size: font_size[:heading],
    style: :bold,
    leading: line_height * font_size[:heading]
  )
end

DOC_MARGIN = {:top => 2.cm, :right => 3.05.cm, :bottom => 2.cm, :left => 3.05.cm}
FONT_SIZE = {:heading => 9.5, :body => 9.5}

Prawn::Document.generate(
  "output.pdf",
  page_size: "A4",
  margin: [DOC_MARGIN[:top], DOC_MARGIN[:right], DOC_MARGIN[:bottom], DOC_MARGIN[:left]]
) do

  load_font

  [{level: 4, text: "Introduction"}].each do |heading|
    draw_heading(heading, FONT_SIZE)

    intro_info = [
      "사용자 관점에서 소프트웨어 제작을 추구합니다. 개인적으로 경험했던 불편함을 해소할 수 있는 프로그램을 만들고, 써보며 개선합니다. 최근엔 가계부 입력 및 분석을 도와주는 프로그램을 만들고 있습니다.",
      "저뿐만 아니라 동료가 읽기 좋은 코드를 작성하고자 노력하고, 테스트를 이용해 오류 발생을 막는 습관을 가지고 있습니다.",
      "지속적인 커뮤니티 활동을 통해 상호 성장하는 것을 가치 있게 생각합니다. 사내에서 버전 관리 세미나를 한 경험이 있고, 매주 관심있는 기술을 이야기하는 모임을 6개월 이상 지속한 적이 있습니다. 현재는 개발 관련 모임에 지속적으로 참여하고 있습니다."
    ]

    intro_info.each do |item|
      indent(width_of("- ")) do
        text(
          "- #{item}",
          size: FONT_SIZE[:body],
          leading: 8,
          indent_paragraphs: 0
        )
      end

      space_after_list_item
    end
  end

  space_after_paragraph

  [{ level: 4, text: "Education" }].each do |heading|
    draw_heading(heading, FONT_SIZE)

    education_info = [
      ["에프랩 백엔드 멘토링 과정 수료", "2022.06 ~ 2022.12"],
      ["인천 대학교 대학원 건설환경공학과 석사", "2017.09 ~ 2019.02"],
      ["인천 대학교 건설환경공학과 졸업", "2011.03 ~ 2017.08"]
    ]

    left_col_width = 180 # Adjust based on content and page layout needs
    right_col_start = left_col_width + 10 # Spacing between columns
    education_info.each do |left_text, right_text|
      # Draw left column text
      text_box(
        left_text,
        size: FONT_SIZE[:body],
        at: [0, cursor],
        width: left_col_width,
        align: :left
      )

      # Draw right column text, positioned to start at the right_col_start
      text_box(
        right_text,
        size: FONT_SIZE[:body],
        at: [right_col_start, cursor],
        width: bounds.width - right_col_start,
        align: :left
      )

      move_down 15 # Space between rows; adjust as needed
    end
  end

  space_after_paragraph

  [{ level: 4, text: "Work Experience" }].each do |heading|
    draw_heading(heading, FONT_SIZE)

    work_info = [{
      :company_nm => "(주) 두잇",
      :work_from_to => "2021.05 ~ 2022.05",
      :solved => [
        {
          :what => "건축 분야 알고리즘 기반 솔루션 개발 참여",
          :details => [
            [
              "트레일러 3D 모델을 보여주는 혼합현실 애플리케이션 개발 (C#, Unity, MRTK)",
              "수치값으로만 확인할 수 있었던 알고리즘 연산 결과를 3D 형태로 시각화해 부재 정보를 편하게 확인",
              "기존에 Unity 기반 2D 방식으로 구현되었으나, 시각적 제한을 개선하기 위해 혼합현실 기술을 도입",
              "사용자 편의성을 고려해 렌더링되는 트레일러의 위치와 조작 방식을 개선하고, 작업자가 현장에서 실제 트레일러와 3D 모델을 비교해볼 수 있도록 3D 모델 확대 기능을 구현"
            ],
            [
              "캐드 소프트웨어 플러그인 개발 (C#, Revit API)",
              "알고리즘 연산에 필요한 입력값을 캐드 프로그램에서 입력하고 추출해 쓸 수 있도록 도와주는 플러그인",
              "캐드 외부에서 부재의 3D 모델을 활용할 수 있도록 건축 부재의 3D 모델링 정보 추출 기능을 구현",
              "기존 건축 설계 과정(설계도 제작) 중에 알고리즘 데이터 입력을 가능하도록 해 사용성을 개선"
            ]
          ]
        },
        {
          :what => "사내 버전 관리 문화 도입",
          :details => [
            [
              "사내 개발 인력 증가로 개별 작업한 프로젝트 소스 코드의 통합 문제가 우려되어 버전 관리를 도입",
              "GitLab 서버 설치, 유지 보수 담당 및 사내 팀원에게 Git을 통한 형상 관리 세미나 진행",
              "여러 인원이 참여하는 프로젝트에서 소스 코드 통합 문제 해결에 기여"
            ]
          ]
        }
      ]
    }]

    work_info.each do |wi|
        text(
          wi[:company_nm],
          size: FONT_SIZE[:body],
          leading: 8,
          indent_paragraphs: 0
        )
        space_after_list_item
        text(
          wi[:work_from_to],
          size: FONT_SIZE[:body],
          leading: 8,
          indent_paragraphs: 0
        )
        space_after_list_item
        wi[:solved].each do |solved_item|
          text(
            solved_item[:what],
            size: FONT_SIZE[:body],
            leading: 8,
            indent_paragraphs: 0
          )

          solved_item[:details].map do |detail|
            detail.each do |detail_item|
              indent(width_of("- ")) do
                text(
                  "- #{detail_item}",
                  size: FONT_SIZE[:body],
                  leading: 8,
                  indent_paragraphs: 0
                )
              end
              space_after_list_item
            end
            space_after_list_item
            space_after_list_item
            space_after_list_item
          end
        end
    end
  end

  headings = [
    # { level: 4, text: "Portfolio" }
  ]
end
