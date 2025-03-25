module MkResume
  class FontManager
    def load_font(pdf_doc)
      Prawn::Font::AFM.hide_m17n_warning = true
      pdf_doc.font_families.update(
        "NotoSans" => {
          normal: "./fonts/NotoSansKR-Regular.ttf",
          bold: "./fonts/NotoSansKR-Bold.ttf"
        }
      )
      pdf_doc.font "NotoSans"
    end
  end
end
