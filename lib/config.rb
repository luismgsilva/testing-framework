require_relative 'directory_manager.rb'

class Config

  @@instance = nil

  def self.get_json(file)
  end 
  def self.instance
    @@instance = @@instance || Config.new
    return @@instance
  end

  def initialize
    file = "#{DirManager.get_config_path}/config.json"
    abort("Not a BSF directory") if !File.exists?(file)
    @config = JSON.parse(File.read(file), symbolize_names: true)
  end

  def self.init_bsf(config_source_path)
    begin
      internal_config_path = DirManager.get_config_path()
      raise("PathMustContainConfigFileException") if !DirManager.file_exists("#{config_source_path}/config.json") 
      raise("AlreadyBSFDirectory") if File.directory? DirManager.get_framework_path
      raise("InvalidConfigFileException") if !valid_json("#{config_source_path}/config.json")
      DirManager.create_dir(internal_config_path)
      raise("CouldNotCopyFilesException") if !DirManager.copy_folder("#{config_source_path}/*", internal_config_path)
      result = {}
      Config.instance.tasks.keys.each { |task| result[task] = 9 } ## NEED TO MODIFIED THIS -------------------
      File.write(DirManager.get_status_file, JSON.pretty_generate(result))
    rescue Exception => e
      p e.message
      abort("ERROR: Already a BSF Directory") if e.message == "AlreadyBSFDirectory"
      abort("ERROR: Invalid Config File") if e.message == "InvalidConfigFileException"
      abort("ERROR: Path must contain config.json file") if e.message == "PathMustContainConfigFileException"
      abort("ERROR: Could not copy Files") if e.message == "CouldNotCopyFilesException"
    end
  end
  
  def self.valid_json(file_path)
    begin 
      config = JSON.parse(File.read(file_path), symbolize_names: true)
      return false if !config.has_key? :sources
      return false if !config.has_key? :tasks
      return true
    rescue => e
      puts e.message
      return false
    end
  end

  def self.save_config(dir_to)
    dir_from = DirManager.get_config_path
    DirManager.create_dir(dir_to)
    DirManager.copy_folder(dir_from, dir_to)
  end 

  def required_variables
    str = JSON.pretty_generate(@config)
    exprex = /\$var\(([^)]+)\)/
    return str.scan(exprex).flatten.uniq
  end

  def tasks
    return @config[:tasks]
  end
  def task_description(task)
    return tasks[task.to_sym][:description]
  end
  def publish_header(task)
    return tasks[task.to_sym][:publish_header]
  end
  def comparator(task)
    return tasks[task.to_sym][:comparator]
  end
  def comparator_agregator()
   return @config[:comparator_agregator]
  end 
  def sources
    return @config[:sources]
  end
end
