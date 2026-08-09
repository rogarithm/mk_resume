### 소개
일반 텍스트로 작성한 이력서의 각 섹션을 조합해 PDF 이력서를 생성해주는 도구

### 문제 정의
- 기존에는 Pages 앱으로 이력서를 만들어 관리했지만, 시간이 지날수록 번거로운 경우가 생겼다
- 바꿀 내용이 제대로 적용되었는지 확인하기가 어려웠다. 회사마다 요구하는 이력서 형식이 다른 경우가 종종 있었고, 이에 더해 경력 기술과 포트폴리오 내용을 최신화하거나 수정하기도 해야 해서 변경 사항이 여러 군데 생기기 때문이었다
- 또한 Pages는 WISIWIG 방식이라 문서 내용과 포맷팅을 함께 다뤄야 했고, 그래서 글을 고치면 문서 전반적으로 포맷을 다시 점검하고 수정해야 했다
- Pages 문서는 텍스트 기반이 아니라 버전 관리가 어려워, 매번 필요한 정보가 빠지지 않았는지 문서를 일일이 확인해야 했기 때문에 변경 사항이 제대로 적용되었는지 확인하기 어려웠다

### 해결 방안
- 이력서를 구성하는 각 [텍스트 파일 섹션](spec/data/src/)을 읽어와 조합하고, 하나의 PDF 이력서로 변환하는 도구를 만든다
- 각 섹션은 `markdown` 마커로 시작하는 플레인 텍스트로 작성하고, [MarkdownParser](lib/mk_resume/markdown_parser.rb)와 [PdfTypesetter](lib/mk_resume/pdf_typesetter.rb)로 파싱 및 렌더링한다
- 이를 통해 다양한 요구사항에 맞는 형태로 쉽게 조합할 수 있게 한다
- 이력서 내용은 플레인 텍스트로 써서 버전 관리할 수 있게 하고, 포맷은 프로그램 안에서 관리해서 이력서 포맷 재사용을 덜 번거롭게 한다

### 작동 방식
- [DocumentWriter](lib/mk_resume/document_writer.rb)가 섹션 파일들을 읽는다
- [PdfTypesetter](lib/mk_resume/pdf_typesetter.rb)가 섹션 내용에 맞는 렌더링 전략을 선택한다
- `markdown` 마커가 있는 섹션은 [MarkdownParser](lib/mk_resume/markdown_parser.rb)로 노드 트리를 만들고, [FormattingConfig](lib/mk_resume/formatting_config.rb)의 스타일 설정으로 렌더링한다
- 최종 결과를 Prawn 기반 PDF로 생성한다

### 의존성
- Ruby
- `prawn`
- `prawn-measurement_extensions`
- 한글 출력을 위해 `fonts/` 아래의 Noto Sans KR 폰트 파일을 사용한다

### 프로그램 실행 방법
- `$ rake sample`: 샘플용 이력서를 만든다. 입력 소스로 프로젝트 내부의 [`spec/data/src`](spec/data/src/)를 사용한다
- `$ rake prod`: 실제로 쓸 이력서를 만든다. 입력 소스로 프로젝트 바깥의 `../../../src` 디렉토리를 사용한다

