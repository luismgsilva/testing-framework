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
  return get_default + "/install"
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
    opt.on('--module MODULE') { |o| options.module = o }
    opt.on('--arc-tools ARC-TOOLS') { |o| options.arctools = o }
  end.parse!
  return options
end

def process_env(str, prefix)
  return str.gsub(/\$env\(([A-Z0-9_]+)\)/) do |m|
    prefix
  end
end

def file_management(root_, module_directory_, prefix_, options)
  
  root = (! options.arctools.to_s.empty?) ? options.arctools.to_s + "/arc-tools/" : get_default()
  Dir.mkdir(root) if ! File.directory? (root)

  module_directory = ((! options.module.to_s.empty?) ? options.module.to_s : root) + "/modulefiles/"
  Dir.mkdir(module_directory) if ! File.directory? (module_directory)

  %w[toolchain toolchain/build].each { |dir| Dir.mkdir (root + dir) }

  prefix = ((options.prefix.to_s.empty?) ? root + "/install/" : options.prefix.to_s) # + "/#{get_current_date}/"

  prefix_ << prefix
  root_ << root
  module_directory_ << module_directory

end


def create_module_file(module_directory, prefix, name)
  
  module_file_directory = module_directory + "/#{name}/"
  Dir.mkdir(module_file_directory) if ! File.directory? (module_file_directory)
   
  template = ERB.new(File.read("toolchain.module.erb"))
  File.open(module_file_directory + get_current_date() + '.lua', 'w') do |f|
    f.write template.result(binding)
  end
end

def create_build_directory(root, name)
  build_directory = root + "/toolchain/build/#{name}/"
  Dir.mkdir(build_directory) if ! File.directory? (build_directory)
  Dir.chdir(build_directory)
end

def main()
  data = get_data()  
  options = get_options()
 
  root = ""
  module_directory = ""
  prefix = ""

  file_management(root, module_directory, prefix, options) 
  puts root
  puts module_directory
  puts prefix

  for arc in data
   
    create_module_file(module_directory, prefix, arc[0].to_s)

    create_build_directory(root, arc[0].to_s)
    execute = process_env(arc[1]['execute'], "#{prefix}/#{arc[0].to_s}/#{get_current_date}/")
    system(execute)

    
    exit
  end
end


main() 

