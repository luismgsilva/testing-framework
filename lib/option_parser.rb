module OptionParser

  class OptionParser
    def initialize
      @conditions = {}
      @default = nil
    end
    def condition(pattern, &action)
      @conditions[pattern] = action
    end

    def default(&action)
      @default_action = action
    end

    def self.match_condition(condition, args)
      opts = {}
      i = 0
      isFinal = false
      condition.split(" ").each do |c|
          count = 1
          # eg. c == "compare" ; args[i] == "compare"
          i += count and next if (c =~ /^-?[A-Za-z0-9_]+$/ && c == args[i])

          if args[i] =~ /.=./ and c =~ /^<([^}]+)>=<([^}]+)>$/ and !args[i].nil?
              tmp1 = $1
              tmp2 = $2
              if args[i] =~ (/^([^}]+)=([^}]+)$/)
                opts[tmp1] = $1
                opts[tmp2] = $2
              end

          elsif c =~ /^\$([{}<>A-Za-z0-9_]+)$/
            tmp = $1

            if tmp =~ /^<([A-Za-z0-9_]+)>$/
              if !args[i].nil?
                opts[$1] = args[i..-1]
                isFinal = true
              elsif args[i].nil
                opts = nil
                break
              end
            elsif tmp =~ /^{([A-Za-z0-9_]+)}$/ and !args[i].nil?
              opts[$1] = args[i..-1]
              isFinal = true
            end

          elsif(c =~ /^<([A-Za-z0-9_]+)>$/ and !args[i].nil?)
            opts[$1] = args[i]

          elsif (c =~ /^{([^}]+)}$/)
            tmp = $1
            if tmp =~ /^-([A-Za-z0-9_]+)$/
              if args[i] == tmp
                opts[$1] = {}
              else
                count = 0
              end
            elsif tmp =~ /^([A-Za-z0-9_]+)$/ and !args[i].nil?
              opts[tmp] = args[i]
            end
          else
              opts = nil
              break;
          end
          i += count
      end

      opts = nil if i < args.count and !isFinal
      opts.transform_keys!(&:to_sym) if !opts.nil?

      return opts
    end
    # def self.match_condition(condition, args)
    #   opts = {}
    #   i = 0
    #   isFinal = false
    #   condition.split(" ").each do |c|
    #       count = 1
    #       # eg. c == "compare" ; args[i] == "compare"
    #       i += count and next if (c =~ /^-?[A-Za-z0-9_]+$/ && c == args[i])
    #       # eg. c == "PREFIX=path/to/prefix"
    #       if args[i] =~ /.=./ and c =~ /^<([^}]+)>=<([^}]+)>$/ and !args[i].nil?
    #           tmp1 = $1
    #           tmp2 = $2
    #           if args[i] =~ (/^([^}]+)=([^}]+)$/)
    #             opts[tmp1] = $1
    #             opts[tmp2] = $2
    #           end

    #       # Options
    #       elsif(c =~ /^{([^}]+)}$/)
    #           tmp  = $1
    #           if tmp =~ /^-([^}]+)$/
    #             if args[i] == tmp
    #               opts[$1] = {}
    #             else
    #               count = 0
    #             end

    #           elsif tmp =~ /^\$<([A-Za-z0-9_]+)>$/ and !args[i].nil?
    #             opts[$1] = args[i..-1]
    #             isFinal = true

    #           elsif tmp =~ /^<([A-Za-z0-9_]+)>$/ and !args[i].nil?
    #               opts[$1] = args[i]
    #           end

    #       elsif c =~ /^\$<([A-Za-z0-9_]+)>$/ and !args[i].nil? #
    #         opts[$1] = args[i..-1]
    #         isFinal = true

    #       elsif(c =~ /^<([A-Za-z0-9_]+)>$/ and !args[i].nil?)
    #           opts[$1] = args[i]
    #       else
    #           opts = nil
    #           break;
    #       end

    #       i += count

    #   end

    #   opts = nil if i < args.count and !isFinal

    #   opts.transform_keys!(&:to_sym) if !opts.nil?

    #   return opts
    # end

    def match_conditions(args)
      @conditions.each_pair do |condition, action|
        opts = OptionParser.match_condition(condition, args)
        if(opts != nil)
          ret = {action: action, opts: opts}
          return ret
        end
      end
      return nil
    end

    def parse(args)
      condition = match_conditions(args)
      if(condition)
        condition[:action].call(condition[:opts])
      else
        @default_action.call() if (@default_action)
        exit -1
      end
    end
  end
end

