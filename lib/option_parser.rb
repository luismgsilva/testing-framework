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
          # eg. c == "PREFIX=path/to/prefix"
          if args[i] =~ /.=./ and c =~ /^<([^}]+)>=<([^}]+)>$/ and !args[i].nil?
              tmp1 = $1
              tmp2 = $2
              if args[i] =~ (/^([^}]+)=([^}]+)$/)
                opts[tmp1] = $1
                opts[tmp2] = $2
              end

          # Options 
          elsif(c =~ /^{([^}]+)}$/)
              tmp  = $1
              if tmp =~ /^-([^}]+)$/
                if args[i] == tmp
                  opts[$1] = {}
                else
                  count = 0
                end
              
              elsif tmp =~ /^\$<([A-Za-z0-9_]+)>$/ and !args[i].nil?
                opts[$1] = args[i..-1]
                isFinal = true
              
              elsif tmp =~ /^<([A-Za-z0-9_]+)>$/ and !args[i].nil?
                  opts[$1] = args[i]
              end
            
          elsif c =~ /^\$<([A-Za-z0-9_]+)>$/ and !args[i].nil? #
            opts[$1] = args[i..-1]
            isFinal = true

          elsif(c =~ /^<([A-Za-z0-9_]+)>$/ and !args[i].nil?)
              opts[$1] = args[i]
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
    #attr_reader :opts
    #def initialize(argv)
   #   @opts = {}
     # set(argv)
   # end
=begin
    def set(argv)
      tmp = argv.shift
      case tmp
      when /init/
        @opts.store(:command, :init)
        @opts.store(:file, argv.shift)
      when /build/
        @opts.store(:command, :build) 
        @opts.store(:build, argv)
      when /log/
        @opts.store(:command, :log)
        %w[-t -tail].each { |flag| @opts.store(:flag, true) if argv.include? flag }
        @opts.store(:log, argv[-1])
      when /help/ 
        @opts.store(:command, :help)
      when /var_list/
        @opts.store(:command, :var_list)
      when /set/
        @opts.store(:command, :set)
        @opts.store(:set, argv.shift)
      when /repo_list/
        @opts.store(:command, :repo_list) 
      when /status/
        @opts.store(:command, :status) 
      when /publish/
        @opts.store(:command, :publish)
      when /clone/
        @opts.store(:command, :clone)
        @opts.store(:clone, argv.shift)
      when /git/
        @opts.store(:command, :git)
        @opts.store(:git, argv.join(" "))
      when /save_config/
        @opts.store(:command, :save_config)
        @opts.store(:save_config, argv.shift)
      when /versions/
        @opts.store(:command, :versions)
        @opts.store(:versions, argv.shift)
      when /tail/
        @opts.store(:command, :tail)
        @opts.store(:tail, argv.shift)
      when /search/
        @opts.store(:command, :search)
        @opts.store(:search, argv)
      when /clean/
        @opts.store(:command, :clean)
      when /compare/
        @opts.store(:command, :compare)
        @opts.store(:json, false) 
        %w[-j -json].each { |j| @opts.store(:json, true) and argv.delete(j) if argv.include? j }
        @opts.store(:compare, argv)
      when /sources/
        @opts.store(:command, :sources)
        @opts.store(:sources, argv)
      end
    
    end
=end
  end
end

