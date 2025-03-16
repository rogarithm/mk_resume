module MkResume
  class Preproc
    def company_nm?(l)
      l =~ /^\s*(company_nm:)/
    end
    def skill_set?(l)
      l =~ /^\s*(skill_set:)/
    end
    def task?(l)
      l =~ /^\s*(task:)/
    end
    def project?(l)
      l =~ /^\s*(project:)/
    end
    def what?(l)
      l =~ /^\s*(what:)/
    end
    def details?(l)
      l =~ /^\s*(details:)/
    end

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

    def group_by_company(obj_in_txt)
      lines = obj_in_txt.split("\n")

      obj = {}
      proj_in_txt = []
      lines.each do |l|
        case
        when company_nm?(l) then
          obj = {}
          obj[:company_nm] = l.split(":")[1].strip
        when skill_set?(l) then
          obj[:skill_set] = l.split(":")[1].strip
        else
          proj_in_txt << l
        end
      end
      obj[:project] = group_project proj_in_txt.join("\n") if proj_in_txt != []
      obj
    end

    def group_project plain_text_project
      lines = plain_text_project.split("\n")

      project = {}
      nm = nil
      task_desc = nil
      lines.each do |l|
        case
        when project?(l) then
          nmish = l.split(":")
          nm = nmish.size == 2 ? nmish[1].strip : l.split(":")[1..-1].join(":").strip
          project[nm] = []
        when task?(l) then
          task_desc = l.split(":").size > 1 ? l.split(":")[1].strip : :EMPTY_TASK_DESC
          project[nm] << {task_desc => []}
        when details?(l) then
          ""
        else
          idx = project[nm].find_index {|e| e[task_desc] != nil}
          project[nm][idx][task_desc] << l.strip
        end
      end
      project
    end
  end
end
