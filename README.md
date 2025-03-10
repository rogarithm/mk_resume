### 경험한 불편함
- Pages 앱으로 이력서를 관리할 때, 레이아웃 설정과 수정에 많은 시간을 들여야 했음

### 구현한 것
- 이력서를 구성하는 각 섹션을 [텍스트 파일](src/)로부터 읽어와 [PDF](output.pdf)로 변환하는 [프로그램](lib/mk_pdf.rb)을 구현
- 중첩 구조 등 복잡한 로직이 필요한 섹션의 경우, [파서](lib/mk_resume/preproc.rb) 구현

### 프로그램으로 개선한 것
- 이력서 레이아웃 조정에 드는 시간이 감소
- 이력서 내용만 텍스트로 분리해 관리할 수 있게 됨

### 프로그램 실행 방법
- `$ rake sample`: 샘플용 이력서를 만든다. 이력서 소스 파일은 프로젝트의 src 디렉토리 안 파일을 쓴다
- `$ rake prod`: 실제로 쓸 이력서를 만든다. 프로젝트 바깥의 src 디렉토리 안 파일을 쓴다
