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
      elsif (opt == '-f')
	tmp = args.shift.split(":")
	@@options[:files] = @@options[:files] || []
	@@options[:files].push({ file: tmp[0], hash: tmp[1]  })
      end
    end
    #@@options[:target] = @@options[:target] || :default
    @@options[:target] = @@options[:target] || :default
    @@options[:target] = :json

    if @@options[:process_opts]
    end
# validar -t -f
  end

  def execute()
    @@data[@@options[:target]].call(@@options)
#    @@data.each_pair do |t, b|
#      b.call()
#    end
  end
end
