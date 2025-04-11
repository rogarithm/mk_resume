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

  context "헤딩 생성 시 자동으로 포맷팅한다" do
    dw = MkResume::DocumentWriter.new

    it "_로 구분되지 않은 경우 헤딩용 제목을 섹션 파일명으로부터 만들 수 있다" do
      expect(dw.capitalize(:portfolio)).to eq("Portfolio")
    end

    it "_로 구분된 경우 헤딩용 제목을 섹션 파일명으로부터 만들 수 있다" do
      expect(dw.capitalize(:side_project)).to eq("Side Project")
    end
  end

  context "텍스트 형식이 어떤지 판단할 수 있다" do
    it "링크 텍스트가 없는 경우" do
      dw = MkResume::DocumentWriter.new
      txt_type_1 = dw.find_txt_type "sample text"
      expect(txt_type_1[:simple_text]).to eq(true)
    end

    it "링크 텍스트만 있는 경우" do
      dw = MkResume::DocumentWriter.new
      txt_type_2 = dw.find_txt_type "<link href='url'>url_txt</link>"
      expect(txt_type_2[:only_link]).to eq(true)
    end

    it "링크 텍스트와 일반 텍스트 둘 다 있는 경우" do
      dw = MkResume::DocumentWriter.new
      txt_type_3 = dw.find_txt_type "blah <link href='url'>url_txt</link> clah"
      expect(txt_type_3[:text_link_combined]).to eq(true)
    end
  end

  context "링크 텍스트 포함 여부에 따라 링크를 자동으로 포맷팅한다" do
    it "링크 텍스트가 없을 경우 text를 따로 포맷팅하지 않고, prawn#text를 호출한다" do
      dw = MkResume::DocumentWriter.new
      fake_doc = FakePrawn.new

      dw.write_text(fake_doc, "sample text")
      expect(fake_doc.txt_args).to eq(["sample text"])
      expect(fake_doc.method_calls[:text]).to eq(1)
      fake_doc.clear
    end

    it "링크 텍스트만 있을 경우 wrap_link를 호출해서 text를 link 형식으로 포맷팅하고, prawn#text를 호출한다" do
      dw = MkResume::DocumentWriter.new
      fake_doc = FakePrawn.new

      link_txt = "<link href='url'>url_txt</link>"
      dw.write_text(fake_doc, link_txt)
      expect(fake_doc.txt_args).to eq([dw.wrap_link(link_txt)])
      expect(fake_doc.method_calls[:text]).to eq(1)
      fake_doc.clear
    end

    it "링크 텍스트와 일반 텍스트가 모두 있을 경우 링크 형식과 그렇지 않은 형식을 따로 구분한다" do
      dw = MkResume::DocumentWriter.new
      link_n_txt = "blah <link href='url'>url_txt</link>"
      expect(dw.wrap_link_n_txt link_n_txt)
        .to eq([
                 { text: "blah ", leading: 6 },
                 { text: " (" },
                 { text: "url_txt", leading: 6, styles: [:underline], color: "888888", link: "url" },
                 { text: ")" }
               ])
    end

    it "링크 텍스트와 일반 텍스트가 모두 있을 경우 write_formatted_text를 호출한다" do
      dw = MkResume::DocumentWriter.new
      fake_doc = FakePrawn.new

      link_n_txt = "blah <link href='url'>url_txt</link>"
      dw.write_text(fake_doc, link_n_txt)
      expect(fake_doc.txt_args).to eq([dw.wrap_link_n_txt(link_n_txt)])
      expect(fake_doc.method_calls[:formatted_text]).to eq(1)
      fake_doc.clear
    end
  end

  class FakePrawn
    attr_reader :txt_args, :method_calls

    def initialize
      @txt_args = []
      @method_calls = Hash.new(0)
    end

    def stroke_horizontal_rule; end
    def move_down point; end
    def text(txt, options)
      @txt_args << txt
      @method_calls[:text] = @method_calls[:text] + 1
    end
    def formatted_text(txts, options)
      @txt_args << txts
      @method_calls[:formatted_text] = @method_calls[:formatted_text] + 1
    end
    def clear
      @txt_args.clear
      @method_calls.clear
    end
  end
end

