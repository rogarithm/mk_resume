module MkResume
  class PdfTypesetter
    def strategy_list
      [
        WorkExpTypesetStrategy.name,
        PortfolioTypesetStrategy.name,
        ListTypesetStrategy.name,
        TwoColumnsTypesetStrategy.name,
        SideProjTypesetStrategy.name
      ]
    end

    def handler section_txt
      strategy_nm = find_strategy(section_txt)
      strategy = Object::const_get(strategy_nm).new
      strategy.handler
    end

    def find_strategy section_txt
      matching_strategy = self.strategy_list.reduce([]) {|result, strategy_nm|
        strategy = Object::const_get(strategy_nm).new
        result << strategy_nm if strategy.can_handle?(section_txt)
        result
      }

      validate_search_result(matching_strategy)
    end

    def validate_search_result matching_strategy
      if matching_strategy.size == 0
        return DefaultTypesetStrategy.name
      end
      if matching_strategy.size > 1
        raise TypesetStrategyFindError.new("found more than one typeset strategy to handle given section text!")
      end
      matching_strategy.first
    end
  end

  class TypesetStrategyFindError < StandardError; end

  module TypesetStrategy
    def can_handle? section_txt
      raise "Not implemented"
    end

    def handler
      raise "Not implemented"
    end
  end

  class SideProjTypesetStrategy
    include TypesetStrategy

    def can_handle? section_txt
      section_txt.split("\n").first.match(/^side_proj_nm:.*$/)
    end

    def handler
      lambda {|section_txt, opts|
        opts[:doc_writer].write_heading(
          opts[:doc],
          :side_project,
          opts[:formatting_config].side_project(:heading, opts[:font_manager])
        )

        side_projs = []
        opts[:parser].segments_by_keyword(section_txt, "side_proj_nm").each do |side_proj|
          side_projs << opts[:parser].make_obj(side_proj.join("\n"), [:side_proj_nm, :proj_link, :proj_desc])
        end

        side_projs.each do |side_proj|
          match = side_proj[:proj_link].match(/<link href='([^']*)'>([^<]*)<\/link>/)
          link_url = match[1]
          link_text = match[2]

          opts[:doc_writer].write_formatted_text(
            opts[:doc],
            [
              { text: side_proj[:side_proj_nm], leading: 6 },
              { text: " (" },
              { text: "#{link_text}", leading: 6, styles: [:underline], color: "888888", link: link_url },
              { text: ")" },
            ],
            opts[:formatting_config].side_project(:project, opts[:font_manager])
          )

          opts[:layout_arranger].v_space(opts[:doc], 2)

          opts[:doc_writer].write_indented_text(
            opts[:doc],
            "      ",
            side_proj[:proj_desc],
            opts[:formatting_config].side_project(:default, opts[:font_manager])
          )
          opts[:layout_arranger].v_space(opts[:doc], 2)
          opts[:layout_arranger].v_space(opts[:doc], 2)
          opts[:layout_arranger].v_space(opts[:doc], 2)
        end

        opts[:layout_arranger].v_space(opts[:doc], 2)
        opts[:layout_arranger].v_space(opts[:doc], 14.5)
      }
    end
  end

  class WorkExpTypesetStrategy
    include TypesetStrategy

    def can_handle? section_txt
      section_txt.split("\n").first.match(/^company_nm:.*$/)
    end

    def handler
      lambda {|section_txt, opts|
        opts[:doc_writer].write_heading(
          opts[:doc],
          :work_experience,
          opts[:formatting_config].work_experience(:heading, opts[:font_manager])
        )

        work_exps = []
        opts[:parser].segments_by_keyword(section_txt).each do |work_exp|
          work_exps << opts[:parser].make_obj(work_exp.join("\n"))
        end

        work_exps.each do |work_exp|
          opts[:doc_writer].write_text(
            opts[:doc],
            work_exp[:company_nm],
            opts[:formatting_config].work_experience(:default, opts[:font_manager])
                              .merge!({:line_spacing_pt => 2})
          )
          opts[:doc_writer].write_text(
            opts[:doc],
            "사용기술: #{work_exp[:skill_set]}",
            opts[:formatting_config].work_experience(:long_leading, opts[:font_manager])
                              .merge!({:line_spacing_pt => 2})
          ) if work_exp[:skill_set]

          work_exp[:project].keys.each do |task|
            opts[:doc_writer].write_text(
              opts[:doc],
              task,
              opts[:formatting_config].work_experience(:default, opts[:font_manager])
            )

            work_exp[:project][task].each do |task_info|
              task_info.each_key {|task_desc|
                opts[:doc_writer].write_indented_text(
                  opts[:doc],
                  "      ",
                  task_desc,
                  opts[:formatting_config].work_experience(:default, opts[:font_manager])
                ) if task_desc != :EMPTY_TASK_DESC
                task_details = task_info[task_desc]
                task_details.each do |task_detail|
                  opts[:doc_writer].write_indented_text(
                    opts[:doc],
                    "      ",
                    "- #{task_detail}",
                    opts[:formatting_config].work_experience(:default, opts[:font_manager])
                                      .merge!({:line_spacing_pt => 2})
                  )
                end
                opts[:layout_arranger].v_space(opts[:doc], 2)
                opts[:layout_arranger].v_space(opts[:doc], 2)
                opts[:layout_arranger].v_space(opts[:doc], 2)
              }
            end
          end
        end

        opts[:layout_arranger].v_space(opts[:doc], 2)
        opts[:layout_arranger].v_space(opts[:doc], 14.5)
      }
    end
  end

  class PortfolioTypesetStrategy
    include TypesetStrategy

    def can_handle? section_txt
      section_txt.split("\n").first.match(/^portfolio_nm:.*$/)
    end

    def handler
      lambda {|section_txt, opts|
        opts[:doc_writer].write_heading(
          opts[:doc],
          :portfolio,
          opts[:formatting_config].portfolio(:heading, opts[:font_manager])
        )

        portfolios = []
        opts[:parser].segments_by_keyword(section_txt, "portfolio_nm").each do |portfolio|
          portfolios << opts[:parser].make_obj(portfolio.join("\n"),
            [:portfolio_nm, :desc, :repo_link, :service_link, :swagger_link, :tech_stack],
            MkResume::PortfolioProjectMaker)
        end

        portfolios.each do |portfolio|
          match = portfolio[:repo_link].match(/<link href='([^']*)'>([^<]*)<\/link>/)
          link_url = match[1]
          link_text = match[2]

          opts[:doc_writer].write_formatted_text(
            opts[:doc],
            [
              { text: portfolio[:portfolio_nm], leading: 6 },
              { text: " (" },
              { text: "#{link_text}", leading: 6, styles: [:underline], color: "888888", link: link_url },
              { text: ")" },
            ],
            opts[:formatting_config].portfolio(:project, opts[:font_manager])
          )
          opts[:layout_arranger].v_space(opts[:doc], 10)

          opts[:doc_writer].write_text(
            opts[:doc],
            portfolio[:desc],
            opts[:formatting_config].portfolio(:default, opts[:font_manager])
                                    .merge!({:line_spacing_pt => 2})
          )

          opts[:doc_writer].write_text(
            opts[:doc],
            "사용 기술: #{portfolio[:tech_stack]}",
            opts[:formatting_config].portfolio(:default, opts[:font_manager])
                                    .merge!({:line_spacing_pt => 2})
          )

          opts[:doc_writer].write_text(
            opts[:doc],
            "담당 작업",
            opts[:formatting_config].portfolio(:default, opts[:font_manager])
          )
          portfolio[:project][:tasks].each do |task|
            opts[:doc_writer].write_indented_text(
              opts[:doc],
              "  ",
              "- #{task}",
              opts[:formatting_config].portfolio(:default, opts[:font_manager])
                                      .merge!({:line_spacing_pt => 2})
            )
          end
          opts[:layout_arranger].v_space(opts[:doc], 2)

          portfolio[:project][:trouble_shooting].each do |trb_sht_info|
            trb_sht_info.each_key do |trb_sht_desc|
              opts[:doc_writer].write_text(
                opts[:doc],
                "해결한 문제: #{trb_sht_desc}",
                opts[:formatting_config].portfolio(:default, opts[:font_manager])
              )

              trb_sht_info[trb_sht_desc].each do |trb_sht_detail|
                opts[:doc_writer].write_indented_text(
                  opts[:doc],
                  "  ",
                  "- #{trb_sht_detail}",
                  opts[:formatting_config].portfolio(:default, opts[:font_manager])
                                          .merge!({:line_spacing_pt => 2})
                )
              end
              opts[:layout_arranger].v_space(opts[:doc], 2)
              opts[:layout_arranger].v_space(opts[:doc], 2)
              opts[:layout_arranger].v_space(opts[:doc], 2)

            end
          end

          opts[:layout_arranger].v_space(opts[:doc], 2)
          opts[:layout_arranger].v_space(opts[:doc], 2)
          opts[:layout_arranger].v_space(opts[:doc], 2)
        end

        opts[:layout_arranger].v_space(opts[:doc], 2)
        opts[:layout_arranger].v_space(opts[:doc], 14.5)
      }
    end
  end

  class ListTypesetStrategy
    include TypesetStrategy

    def can_handle? section_txt
      lines = section_txt.split("\n")
      lines.size == lines.filter {|l| l.match(/^\s*-\s+.*$/)}.size
    end

    def handler
      lambda {|section_txt, opts|
        opts[:doc_writer].write_heading(
          opts[:doc],
          :introduction,
          opts[:formatting_config].introduction(:heading, opts[:font_manager])
        )

        section_txt.split("\n").each do |txt|
          opts[:doc_writer].write_indented_text(
            opts[:doc],
            "- ",
            txt,
            opts[:formatting_config].introduction(:default, opts[:font_manager])
                              .merge!({:line_spacing_pt => 2})
          )
        end

        opts[:layout_arranger].v_space(opts[:doc], 14.5)
      }
    end
  end

  class TwoColumnsTypesetStrategy
    include TypesetStrategy

    def can_handle? section_txt
      lines = section_txt.split("\n")
      lines.size == lines.filter { |l| l.match(/^.*\s*\|\s*.*$/) }.size
    end

    def handler
      lambda {|section_txt, opts|
        opts[:doc_writer].write_heading(
          opts[:doc],
          :education,
          opts[:formatting_config].education(:heading, opts[:font_manager], opts[:doc])
        )

        section_txt.split("\n")
                            .map! { |cols|
                              cols.split("|")
                                  .each { |col| col.strip! }
                            }.each do |left_text, right_text|
          opts[:doc_writer].write_text_box(
            opts[:doc],
            left_text,
            opts[:formatting_config].education(:left, opts[:font_manager], opts[:doc])
          )

          opts[:doc_writer].write_text_box(
            opts[:doc],
            right_text,
            opts[:formatting_config].education(:right, opts[:font_manager], opts[:doc])
          )

          opts[:layout_arranger].v_space(opts[:doc], 15)
        end
      }
    end
  end

  class DefaultTypesetStrategy
    include TypesetStrategy

    def can_handle? section_txt
      true
    end

    def handler
      lambda {|section_txt, opts|
        section_txt.split("\n")[0..4].each.with_index do |text, idx|
          opts[:doc_writer].write_text(
            opts[:doc],
            text,
            opts[:formatting_config].personal_info(idx, opts[:font_manager])
          )
        end
        opts[:layout_arranger].v_space(opts[:doc], 14.5)
      }
    end
  end
end
