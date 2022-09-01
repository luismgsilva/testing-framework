class VarManager

  @@instance = nil

  def initialize
    begin
      @vars = JSON.parse(File.read(DirManager.get_vars_file))
    rescue
      @vars = JSON.parse("{}")
    end
    return self
  end
  def self.instance
    @@instance = @@instance || self.new
    return @@instance
  end

  def internal_vars
    [ "@SOURCE", "@BUILDNAME", "@PERSISTENT_WS", "@WORKSPACE", "@BASELINE", "@REFERENCE", "@CONFIG_SOURCE_PATH" ]
  end
  def var_list()
    var_list = Config.instance.required_variables

    params = @vars.keys
    internal_vars.each { |var| params.push(var) }

    var_list.each do |var|
      if(var =~ /^\@/)
        if(!params.include?(var))
          puts "Internal Variable #{var} is invalid"
        end
      else
        if !params.include?(var)
          puts "Input Variable #{var} not defined"
        else
          puts "Input Variable #{var} defined: #{@vars[var]}"
        end
      end
    end
  end

  def get(varname)
    @vars[varname]
  end

  def save
    File.write(DirManager.get_vars_file, JSON.pretty_generate(@vars))
  end

  def set(var, value)
    abort("ERROR: not a editable variable") if var =~/[\@]/
    abort("ERROR: #{var} not a variable") unless Config.instance.required_variables.include?(var)

    @vars[var] = value
  end
  def set_internal(var, value)
    @vars[var] = value
  end

  #def check_var_global(builder)
  #  vars.select! { |a| a =~ /\@/ }
  #  vars = get_global_var_matching(vars)
  #
  #  abort("ERROR: Internal Variable/s #{vars} not defined.") if !vars.empty?
  #end

  #def get_global_var_matching(vars)
  #    arr = []
  #    vars.each do |var|
  #        tmp = var.gsub("@", "$").to_sym
  #        arr.append(var) if !global_variables.include? (tmp)
  #    end
  #    return arr
  #end

  def process_variables(str)
    return str.gsub(/\$var\(([A-Z0-9_@]+)\)/) do |m|
      var_name = $1
      abort("Input variable not set #{$1}.") if @vars[var_name].nil?
      @vars[var_name]
    end
  end

  def prepare_data(hash)
    str = JSON.pretty_generate(hash)
    str = process_variables(str)
    return JSON.parse(str)
  end

end
