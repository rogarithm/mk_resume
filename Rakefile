require_relative './lib/mk_pdf'

desc "실제로 쓸 이력서를 만든다. 현재 최상위 디렉토리 바깥 src 디렉토리의 이력서 플레인 텍스트를 소스로 쓴다"
task :prod do
  run %W[.. .. src]
end

desc "샘플용 이력서를 만든다. 현재 최상위 디렉토리 하위의 src 디렉토리에 이력서 플레인 텍스트를 소스로 쓴다"
task :sample do
  run %W[.. src]
end
