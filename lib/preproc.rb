class Preproc

  def company_nm?(l)
    l =~ /^\s*(company_nm:)/
  end
  def work_from_to?(l)
    l =~ /^\s*(work_from_to:)/
  end
  def solved?(l)
    l =~ /^\s*(solved:)/
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
        res << lines[range...ranges[idx + 1]]
      end
    end
  end

  def group_by_company(work_exp)
    lines = work_exp.split("\n")

    group = {}
    solve = []
    lines.each do |l|
      case
      when company_nm?(l) then
        group = {}
        group[:company_nm] = l.split(":")[1].strip
      when work_from_to?(l) then
        group[:work_from_to] = l.split(":")[1].strip
      else
        solve << l
      end
    end
    group[:project] = group_solved solve.join("\n") if solve != []
    group
  end

  def group_solved sol
    lines = sol.split("\n")

    solved_tasks = {}
    solved_task_nm = nil
    solve_what = nil
    lines.each do |l|
      case
      when project?(l) then
        solved_task_nm = l.split(":")[1].strip
        solved_tasks[solved_task_nm] = []
      when what?(l) then
        solve_what = l.split(":").size > 1 ? l.split(":")[1].strip : :EMPTY_WHAT
        solved_tasks[solved_task_nm] << {solve_what => []}
      when details?(l) then
        ""
      else
        idx = solved_tasks[solved_task_nm].find_index {|e| e[solve_what] != nil}
        solved_tasks[solved_task_nm][idx][solve_what] << l.strip
      end
    end
    solved_tasks
  end
end