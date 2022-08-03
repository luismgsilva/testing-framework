module OptionParser
  
  class OptionParser
    attr_reader :opts
    def initialize(argv)
      @opts = {}
      set(argv)
    end

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
        @opts.store(:log, argv.shift)
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
        @opts.store(:publish, argv.shift)
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
      when /compare/
        @opts.store(:command, :compare)
        @opts.store(:compare, argv)
      end
    
    end
  end
end

