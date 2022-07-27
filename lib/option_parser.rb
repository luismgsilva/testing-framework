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
        @opts.store(:build, argv.shift)
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
      when /clone/
        @opts.store(:command, :clone)
        @opts.store(:clone, argv.shift)
      when /git/
        @opts.store(:command, :git)
        @opts.store(:git, argv.join(" "))
      when /runtest/
        @opts.store(:command, :runtest)
      end
    
    end
  end
end

