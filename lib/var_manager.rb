require_relative './exceptions.rb'

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
    [ "@SOURCE", "@BUILDNAME", "@PERSISTENT_WS",
      "@WORKSPACE", "@BASELINE", "@REFERENCE",
      "@CONFIG_SOURCE_PATH", "@OPTIONS", "@ROOT",
      "@AGREGATOR"
    ]
  end

  def var_list
    var_list = Config.instance.required_variables
    params = @vars.keys + internal_vars

    str = ""
    var_list.each do |var|
      if var.start_with?("@") && !params.include?(var)
        str += "Internal Variable #{var} is invalid\n"
      elsif !var.start_with?("@") && !params.include?(var)
        str +=  "Input Variable #{var} not defined\n"
      elsif !var.start_with?("@") && params.include?(var)
        str +=  "Input Variable #{var} defined: #{@vars[var]}\n"
      end
    end
    return str
  end

  def get(varname)
    @vars[varname]
  end

  def save
    File.write(DirManager.get_vars_file, JSON.pretty_generate(@vars))
  end

  def set(var, value)
    if var =~/[\@]/
      raise Ex::NotEditableVariableException
    end

    if !Config.instance.required_variables.include?(var)
      raise Ex::NotAVariableException.new(var)
    end

    @vars[var] = value
  end
  def set_internal(var, value)
    @vars[var] = value
  end

  def process_variables(str)
    return str.gsub(/\$var\(([a-zA-Z0-9_@]+)\)/) do |m|
      var_name = $1
      if @vars[var_name].nil?
        raise Ex::InputVariableNotSetException.new(var_name)
      end
      @vars[var_name]
    end
  end

  def prepare_data(data)
    type = data.class
    case type.to_s
    when "Hash"
      str = JSON.pretty_generate(data)
      str = process_variables(str)
      return JSON.parse(str)
    when "String"
      str = process_variables(data)
      return str
    when "Array"
      str = data.join("\n")
      str = process_variables(str)
      return str.split("\n")
    end
  end
end
