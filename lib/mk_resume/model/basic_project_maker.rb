module MkResume
  module Model
    class BasicProjectMaker
      def make proj_in_txt
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
end
