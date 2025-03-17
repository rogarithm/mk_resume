module MkResume
  class Preproc
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

    def make_obj(obj_in_txt, kw_list = [:company_nm, :skill_set], proj_klass = MkResume::BasicProject)
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

      proj_maker = proj_klass.new
      method = proj_maker.method(:make_proj_obj)
      obj[:project] = method.call(proj_in_txt.join("\n")) if proj_in_txt != []
      obj
    end
  end

  class BasicProject
    def make_proj_obj proj_in_txt
      lines = proj_in_txt.split("\n")

      proj = {}
      nm = nil
      task_desc = nil
      lines.each do |l|
        case
        when project?(l) then
          nm = l.split(":", 2)[1].strip
          proj[nm] = []
        when task?(l) then
          task_desc = l.split(":").size > 1 ? l.split(":")[1].strip : :EMPTY_TASK_DESC
          proj[nm] << {task_desc => []}
        when details?(l) then
          ""
        else
          idx = proj[nm].find_index {|e| e[task_desc] != nil}
          proj[nm][idx][task_desc] << l.strip
        end
      end
      proj
    end

    def task?(l)
      l =~ /^\s*(task:)/
    end
    def project?(l)
      l =~ /^\s*(project:)/
    end
    def details?(l)
      l =~ /^\s*(details:)/
    end
  end
end
