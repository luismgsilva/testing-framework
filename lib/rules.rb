module Rules
  @@data = {}
  @@options = {}

  def to_jso(&block)
    @@data[:json] = block
  end
  def to_text(&block)
    @@data[:text] = block
  end
  def default(&block)
    @@data[:default] = block
  end
  def Rules.included(mod)
    process_opts(ARGV)
  end 
  def process_opts(args)
    while(args[0] =~ /^-[a-z]$/)
      opt = args.shift
      if (opt == '-t')
 	@@options[:target] = args.shift.to_sym
      elsif (opt == '-h')
	@@options[:hashs] = @@options[:hashs] || []
	@@options[:hashs].push(args.shift)
      end
    end
    #@@options[:target] = @@options[:target] || :default
    @@options[:target] = @@options[:target] || :json
    @@options[:target] = :json
  end

  def execute()
    @@data[@@options[:target]].call(@@options)
#    @@data.each_pair do |t, b|
#      b.call()
#    end
  end
end
