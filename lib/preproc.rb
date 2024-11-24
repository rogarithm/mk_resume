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
    plain_text_project = []
    lines.each do |l|
      case
      when company_nm?(l) then
        group = {}
        group[:company_nm] = l.split(":")[1].strip
      when work_from_to?(l) then
        group[:work_from_to] = l.split(":")[1].strip
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
    solved_what = nil
    lines.each do |l|
      case
      when project?(l) then
        nmish = l.split(":")
        nm = nmish.size == 2 ? nmish[1].strip : l.split(":")[1..-1].join(":").strip
        project[nm] = []
      when solved?(l) then
        solved_what = l.split(":").size > 1 ? l.split(":")[1].strip : :EMPTY_WHAT
        project[nm] << {solved_what => []}
      when details?(l) then
        ""
      else
        idx = project[nm].find_index {|e| e[solved_what] != nil}
        project[nm][idx][solved_what] << l.strip
      end
    end
    project
  end
end