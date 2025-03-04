require_relative './lib/mk_resume'

desc "실제로 쓸 이력서를 만든다. 현재 최상위 디렉토리 바깥 src 디렉토리의 이력서 플레인 텍스트를 소스로 쓴다"
task :prod do
  run %W[.. .. src]
end

desc "샘플용 이력서를 만든다. 현재 최상위 디렉토리 하위의 src 디렉토리에 이력서 플레인 텍스트를 소스로 쓴다"
task :sample do
  run %W[.. src]
end

desc "생성 결과가 달라지지 않았는지 확인한다"
task :test do
  run %W[.. src]
  x = `git diff --no-index ./output.pdf spec/data/sample.pdf`
  if x.strip != ""
    puts 'generated pdf is different from base pdf!'
  else
    puts 'ok!'
  end
end