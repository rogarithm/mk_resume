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

    def split_by_company work_exp
      lines = work_exp.split("\n")

      ranges = []
      lines.select {|l| company_nm?(l)}.each do |l|
        ranges << lines.find_index(l)
      end
      res = []
      ranges.each.with_index do |range, idx|
        if (idx == ranges.length - 1)
          res << lines[range..(lines.length - 1)]
          return res
        else
          res << lines[range...ranges[idx + 1]].delete_if {|l| l == ""}
        end
      end
    end

    def group_by_company(work_exp)
      lines = work_exp.split("\n")

      group = {}
      plain_text_project = []
      lines.each do |l|
        case
        when company_nm?(l) then
          group = {}
          group[:company_nm] = l.split(":")[1].strip
        when skill_set?(l) then
          group[:skill_set] = l.split(":")[1].strip
        else
          plain_text_project << l
        end
      end
      group[:project] = group_project plain_text_project.join("\n") if plain_text_project != []
      group
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
