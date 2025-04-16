require_relative './lib/mk_resume'

desc "실제로 쓸 이력서를 만든다. 현재 최상위 디렉토리 바깥 src 디렉토리의 이력서 플레인 텍스트를 소스로 쓴다"
task :prod do
  ResumePrinter.new.print %W[.. .. .. src]
end

desc "샘플용 이력서를 만든다. 현재 최상위 디렉토리 하위의 src 디렉토리에 이력서 플레인 텍스트를 소스로 쓴다"
task :sample do
  ResumePrinter.new.print %W[.. .. spec data src]
end

desc "생성 결과가 달라지지 않았는지 확인한다"
task :test do
  ResumePrinter.new.print %W[.. .. spec data src]
  x = `git diff --no-index ./output.pdf spec/data/sample.pdf`
  if x.strip != ""
    puts 'generated pdf is different from base pdf!'
  else
    puts 'ok!'
  end
end

desc "비교 기준이 될 섹션 하나에 대한 pdf를 생성한다"
task :base_only do
  [
    :personal_info, :introduction, :portfolio,
    :work_experience, :side_project, :education
  ].each do |section_nm|
    ResumePrinter.new.print(
      %W[.. .. spec data src],
      [section_nm],
      "./test/base_data/sample_#{section_nm}"
    )
  end
end

desc "생성 결과가 달라지지 않았는지 확인한다"
task :test_only, [:section_nm] do |ignore, args|
  if args[:section_nm].nil?
    abort("empty section name. abort...")
  end

  section_nm = args[:section_nm].to_sym
  ResumePrinter.new.print(
    %W[.. .. spec data src],
    [section_nm],
    "temp_#{section_nm}"
  )
  x = `git diff --no-index ./temp_#{section_nm}.pdf ./test/base_data/sample_#{section_nm}.pdf`
  if x.strip != ""
    puts 'generated pdf is different from base pdf!'
  else
    puts 'ok!'
  end
end
