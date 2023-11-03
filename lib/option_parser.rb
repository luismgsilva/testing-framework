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

    def error(message = nil, rules = nil)
      puts "#{message}. See 'bsf'." if message
      exit
    end

    def print_helper()
      @default_action.call() if (@default_action)
    end

    # def is_debug_info(args)
    #   if args.include?("--enable-debug-info")
    #     Flags.instance.set(:debug_info)
    #   end
    # end

    def parse(args)
      if args.length < 1
        print_helper()
        return
      end

      rule = args.shift
      rule = "#{rule} #{args.shift}" if rule =~ /sources/
      # is_debug_info(args) # WIP

      options = { :flags => {} }
      if rule && @conditions[rule]
        @conditions[rule][:options].each do |o|
          short = o[:short] || "--#{o[:name]}"
          if o[:type] == :equal
            if args[0] =~ (/^([^}]+)=([^}]+)$/)
              options[o[:name].to_sym] = [$1, $2]
            elsif o[:mandatory]
              raise Ex::MissingArgumentException.new(o[:name])
            end

          elsif o[:type] == :param
            if args.include?(o[:short]) || args.include?("--#{o[:name]}")
              i = args.index(o[:short]) || args.index("--#{o[:name]}")
              # options[o[:name].to_sym] = args[i + 1]

              flag_name = o[:name].to_sym
              Flags.instance.set(flag_name, args[i + 1])

              args.delete_at(i+1)
              args.delete_at(i)
            end

          elsif o[:type] == :option
            if args.include?(o[:short]) || args.include?("--#{o[:name]}")
              # options[:flags][o[:name].to_sym] = true

              flag_name = o[:name].to_sym
              Flags.instance.set(flag_name)

            end
            args.delete_if { |op| op == o[:short] || op ==  "--#{o[:name]}"}
          elsif o[:multiple]
            value = []
            while !args.empty?
              break if o[:type] != :args && args[0].start_with?("-")
              value << args.shift
            end
            if value.empty? && o[:mandatory]
              raise Ex::MissingArgumentException.new(o[:name])
            end
            if value.any?
              options[o[:name].to_sym] = value
            end
          elsif !o[:multiple]
            value = args.shift if !args.empty? && !args.first.start_with?("-")
            if value.nil? && o[:mandatory]
              raise Ex::MissingArgumentException.new(o[:name])
            end
            options[o[:name].to_sym] = value
          end
        end if @conditions[rule][:options]
      else
        raise Ex::InvalidCommandException.new(rule)
      end

      @conditions[rule][:action].call(options)
    end
  end
end