require_relative "./model/basic_project_maker"
require_relative "./model/portfolio_project_maker"

module MkResume
  class SectionParser
    def segments_by_keyword objs_in_txt, obj_sep = "company_nm"
      lines = objs_in_txt.split("\n")

      obj_start_idxs = []
      lines.select {|l| l =~ /^\s*(#{obj_sep}:)/}.each do |l|
        obj_start_idxs << lines.find_index(l)
      end
      obj_segments = []
      obj_start_idxs.each.with_index do |obj_stt_idx, idx|
        if (idx == obj_start_idxs.length - 1)
          obj_segments << lines[obj_stt_idx..(lines.length - 1)]
          return obj_segments
        else
          obj_segments << lines[obj_stt_idx...obj_start_idxs[idx + 1]]
                            .delete_if {|l| l == ""}
        end
      end
    end

    def make_obj(obj_in_txt, kw_list = [:company_nm, :skill_set], proj_maker_klass = MkResume::Model::BasicProjectMaker)
      lines = obj_in_txt.split("\n")

      matching_lines = lines.filter {|l|
        kw_list.any? {|kw|
          l =~ /^\s*(#{kw.to_s})/
        }
      }

      obj = {}
      matching_lines.each {|l|
        k_v = l.split(":", 2).map(&:strip)
        obj[k_v[0].to_sym] = k_v[1]
      }

      proj_in_txt = lines - matching_lines

      proj_obj_maker = proj_maker_klass.new
      obj[:project] = proj_obj_maker.method(:make)
                                    .call(proj_in_txt.join("\n")) if proj_in_txt != []
      obj
    end
  end
end
