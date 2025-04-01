module MkResume
  module Model
    class PortfolioProjectMaker
      def make proj_in_txt
        lines = proj_in_txt.split("\n")

        proj = {}
        trb_sht_now = nil
        lines.each do |l|
          case
          when tasks?(l) then
            proj[:tasks] = []
            tasks_idx = lines.find_index { |l| tasks?(l) }
            trb_sht_idx = lines.find_index { |l| trouble_shooting?(l) }
            lines[tasks_idx + 1 .. trb_sht_idx - 1].each {|task|
              proj[:tasks] << task.strip!
            }
          when trouble_shooting?(l) then
            x = proj
            x[:trouble_shooting] = [] if x[:trouble_shooting] == nil
            trb_sht_now = l.split(":", 2)[1].strip!
            x[:trouble_shooting] << {trb_sht_now => []}
          when details?(l) then
            trb_sht_detail_stt = lines.find_index { |l| details?(l) } + 1
            lines[trb_sht_detail_stt..-1].each {|detail|
              idx = proj[:trouble_shooting].find_index {|e| e[trb_sht_now] != nil}
              proj[:trouble_shooting][idx][trb_sht_now] << detail.strip!
            }
          else
            ""
          end
        end
        proj
      end

      def tasks?(l)
        l =~ /^\s*(tasks:)/
      end
      def trouble_shooting?(l)
        l =~ /^\s*(trouble_shooting:)/
      end
      def details?(l)
        l =~ /^\s*(details:)/
      end
    end
  end
end
