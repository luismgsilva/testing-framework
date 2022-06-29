require "erb"
require 'date'
require 'erb'
require 'json'
require 'optparse'
require 'ostruct'

def get_current_date()
  return Date.today.to_s.delete!'-'
end

def get_prefix_default()
  return get_default + "/install/toolchain"
end

def get_default()
  return "/scratch/luiss/arc-tools/"
end

def get_data()
  file = File.read('config.json')
  return JSON.parse(file)
end

def get_options()
  options = OpenStruct.new
  OptionParser.new do |opt|
    opt.on('--prefix PREFIX') { |o| options.prefix = o }
  end.parse!
  return options
end

def process_env(str, prefix)
  return str.gsub(/\$env\(([A-Z0-9_]+)\)/) do |m|
    prefix
  end
end

def create_build_directory(str, name)
  full_directory = get_default() + "toolchain" + str + name
  Dir.mkdir(full_directory)
  Dir.chdir(full_directory)
end

def create_module_file(name)
  
  module_file_directory = get_default() + "modulefiles/" + name
  Dir.mkdir(module_file_directory)
  
  template = ERB.new(File.read("toolchain.module.erb"))
  File.open(module_file_directory + "/" + get_current_date() + '.lua', 'w') do |f|
    f.write template.result(binding)
  end
  
end

def main()
  data = get_data()  
  options = get_options()
   

  for arc in data

    create_module_file(arc[0].to_s)

    create_build_directory("/build/", arc[0].to_s)    

    execute = process_env(arc[1]['execute'], 
                          (options.prefix.to_s.empty?) ? get_prefix_default() : options.prefix)
    system(execute)

    
    exit
  end
end


main() 

