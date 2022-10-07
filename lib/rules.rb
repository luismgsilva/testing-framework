module Rules
  @@data = {}

  def to_json(&block)
    @@data[:to_json] = block
  end
  def to_table(&block)
    @@data[:to_table] = block
  end
  
  def process_opts(args)
    while(args[0] =~ /^-[a-z]$/)
      opt = args.shift
      if (opt == '-t')
        target = args.shift
        @@data.delete_if { |opt| opt != target.to_sym }
      end
    end
    @build_name = args.shift
  end


  def execute()
    @@data.each_pair do |t, b|
    b.call()
    end
  end
end
