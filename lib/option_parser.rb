module OptionParser

  class OptionParser
    def initialize
      @conditions = {}
      @default = nil
    end

    def condition_option(pattern, option)
      @conditions[pattern] ||= {}
      @conditions[pattern][:options] ||= []
      @conditions[pattern][:options] << option
    end

    def condition_action(pattern, &action)
      @conditions[pattern] ||= {}
      @conditions[pattern][:action] = action
    end

    def condition_help(pattern, string)
      @conditions[pattern] ||= {}
      @conditions[pattern][:help] = string
    end

    def default(&action)
      @default_action = action
    end

    def error(message, rules)
      puts message
      @default_action.call() if (@default_action)
      # puts rules[:help]
      # @default_action.call() if (@default_action)
      exit -1
    end


    def parse(args)
      rule = ARGV.shift
      rule = "#{rule} #{ARGV.shift}" if rule =~ /sources/
      options = {}
      if rule && @conditions[rule]
        @conditions[rule][:options].each do |o|
          short = o[:short] || "--#{o[:name]}"
          if o[:type] == :equal
            if ARGV[0] =~ (/^([^}]+)=([^}]+)$/)
              options[o[:name].to_sym] = [$1, $2]
            elsif o[:mandatory]
              error("Error: missing argument #{o[:name]}", @conditions[rule])
            end
          elsif o[:type] == :option
            if ARGV.include?(o[:short]) || ARGV.include?("--#{o[:name]}")
              options[o[:name].to_sym] = true
            end
            ARGV.delete_if { |op| op == o[:short] || op ==  "--#{o[:name]}"}
          elsif o[:multiple]
            value = []
            while !ARGV.empty?
              break if o[:type] != :args && ARGV[0].start_with?("-")
              value << ARGV.shift
            end
            if value.empty? && o[:mandatory]
              error("Error: missing argument #{o[:name]}", @conditions[rule])
            end
            if value.any?
              options[o[:name].to_sym] = value
            end
          elsif !o[:multiple]
            value = ARGV.shift if !ARGV.empty? && !ARGV.first.start_with?("-")
            if value.nil? && o[:mandatory]
              error("Error: missing argument #{o[:name]}", @conditions[rule])
            end
            options[o[:name].to_sym] = value
          end
        end if @conditions[rule][:options]
      else
        error("Error: invalid command #{rule}", @conditions)
      end

      puts "DEBUG: Rule: #{rule}"
      puts "DEBUG: Options: #{options}"

      @conditions[rule][:action].call(options)
    end
  end
end

