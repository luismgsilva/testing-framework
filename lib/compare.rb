#!/usr/bin/env ruby

require 'rubygems'
require 'json'
require 'terminal-table'

module Compare
  class Compare
  
  
    def get_file(dir, task)
      file = "#{dir}/#{task}/gcc.sum"
      abort("#{file} does not exist") unless (File.exists?("#{file}"))
      return file
    end 
  
    def main(dir1, dir2, tasks)
      data = {}
      table = create_table(dir1, dir2, data, tasks)
      puts table
      print_compare(data)
    end

# of expected passes            2533
# of unexpected failures        1280
# of expected failures          19
# of unresolved testcases       124
# of unsupported tests          2583


    def read_results(sum_file)
      mapping = {
        "expected passes" => "PASS",
        "unexpected failures" => "FAIL",
        "unexpected successes" => "XPASS",
        "expected failures" => "XFAIL",
        "unresolved testcases" => "UNRESOLVED",
        "unsupported tests" => "UNSUPPORTED"
      }
      ret = {}
    `tail -n 100 #{sum_file}`.split("\n").each do |l|

        if(l =~ /^# of/)

          l = l.split(/( |\t)/).select { |a| a != " " && a != "\t" && a != "" }
          name = l[2..-2].join(" ")
          num = l[-1].to_i

          ret[mapping[name]] = num
        end
      end
      return ret
    end

    def create_table(dir1, dir2, data, tasks)
      table = Terminal::Table.new do |t|
        
        header = ["", "D(PASS)", "D(FAIL)", "D(NEW)", "D(REM)",
                  "PASS", "FAIL", "XFAIL", "XPASS", "UNRESOLVED", "UNSUPPORTED",
                  "PASS", "FAIL", "XFAIL", "XPASS", "UNRESOLVED", "UNSUPPORTED"
        ]

        t.headings = ["", { value: "Delta", colspan: 4, alignment: :center },
                      { value: dir1, colspan: 6, alignment: :center },
                          { value: dir2, colspan: 6, alignment: :center }]

        t.add_row header
        t.add_separator
        tasks.each do | task, to_execute| 

        results1 = read_results(get_file(dir1, task))
        results2 = read_results(get_file(dir2, task))
        tmp = []
    
        row = [task]
        row[5] = results1["PASS"] || 0
        row[6] = results1["FAIL"] || 0
        row[7] = results1["XFAIL"] || 0
        row[8] = results1["XPASS"] || 0
        row[9] = results1["UNRESOLVED"] || 0
        row[10] = results1["UNSUPPORTED"] || 0
        row[11] = results2["PASS"] || 0
        row[12] = results2["FAIL"] || 0
        row[13] = results2["XFAIL"] || 0
        row[14] = results2["XPASS"] || 0
        row[15] = results2["UNRESOLVED"] || 0
        row[16] = results2["UNSUPPORTED"] || 0
    
        json = JSON.parse(`#{to_execute}`)
        
        row[1] = json["results_delta"]["new_pass"]
        row[2] = json["results_delta"]["new_fail"]
        row[3] = json["results_delta"]["add_test"]
        row[4] = json["results_delta"]["rem_test"]
        t.add_row(row)

        ["new_pass", "new_fail", "add_test", "rem_test"].each do |type|
          if(json["changes"][type].values.count > 0)
            tmp.push("  " + type.gsub("_", " ").capitalize)
            json["changes"][type].each_pair do |t, v|
              tmp.push("    (#{v["before"]}) => (#{v["after"]}) : #{t}")
            end
            tmp.push("")
          end
        end
        data[task] = tmp
        end
      end
      return table
    end

    def print_compare(data)
      data.keys.sort.each do |k|
        v = data[k]
        puts "=== #{k} ==="
        puts v.join("\n")
        puts ""
      end
    end
  end
end

