module Rules
  @@data = {}
  @@options = {}

  def to_jso(&block)
    @@data[:json] = block
  end
  def to_text(&block)
    @@data[:text] = block
  end
  def set_default(name)
    @@options[:default] = name
  end
  def process_opts1(&block)
    @@data[:process_opts] = block
  end
  def Rules.included(mod)
    process_opts(ARGV)
  end
  def process_opts(args)
#    while(args[0] =~ /^-[a-z]$/)
    @@options[:process_opts] = []
    while(args.include?("-h") or args.include?("-o"))
      opt = args.shift
      if (opt == '-o')
 	@@options[:output] = args.shift.to_sym
      elsif (opt == '-h')
	tmp = args.shift.split(":")
	@@options[:files] = @@options[:files] || []
	@@options[:files].push({ file: tmp[0], hash: tmp[1]  })
      else
        @@options[:process_opts].push(opt)
      end
    end
#     @@options[:opts] = args
#    @@options[:output] = @@options[:output] || :default
#    @@options[:process_opts] = args
#    @@options[:target] = :json
# validar -t -f
#    if @@options[:files].nil? || @@options[:target].nil?
#	puts "nao tem files ou target"
#	exit
#    end

#    p @@options[:process_opts]
#exit   
# if @@options[:process_opts]
#    p "dadawd"
#    p args
#exit
#	@@data[@@options[:process_opts]].call(args)
#    end
  end

  def execute()
    
    if @@options[:process_opts]
   p "dawdawd"
      p @@options[:process_opts]
      @@data[:process_opts].call(@@options[:process_opts])
    end
    if(@@options[:output].nil?)
        p @@options[:default]
	@@data[@@options[:default]].call(@@options[:files])
    else
    	@@data[@@options[:output]].call(@@options[:files])
    end
  end
end
