require_relative 'directory_manager.rb'
require_relative './exceptions.rb'


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
    raise Ex::NotBSFDirectoryException if !File.exists?(file)
    # Dont like having to call "Config" class.
    @config = self.class.load_config()
  end

  def self.init_bsf(config_source_path)
    unless DirManager.file_exists("#{config_source_path}/config.json")
      puts config_source_path
      raise Ex::PathMustContainConfigFileException
    end
    if File.directory? DirManager.get_framework_path
      raise Ex::AlreadyBSFDirectoryException
    end

    @config = load_config("#{config_source_path}/config.json")

    internal_config_path = DirManager.get_config_path()
    DirManager.create_dir(internal_config_path)

    unless DirManager.copy_folder("#{config_source_path}/*", internal_config_path)
      raise Ex::CouldNotCopyFilesException
    end

    Status.init_status(@config[:tasks].keys)
  end


  def self.load_config(config_file = "#{DirManager.get_config_path}/config.json")
    config = Validator.validate_configuration_file(config_file)

    Dir.glob(File.join(DirManager.get_config_path, "*.frag")) do | frag_file |
      frag_config = Validator.validate_configuration_file(frag_file)

      config[:sources].merge!(frag_config[:sources])
      config[:tasks].merge!(frag_config[:tasks])
    end

    return config
  end

  def self.save_config(dir_to)
    dir_from = DirManager.get_config_path
    DirManager.create_dir(dir_to)
    DirManager.copy_folder("#{dir_from}/*", dir_to)
    system ("rm -f #{dir_to}/vars.json")
  end

  def required_variables()
    str = JSON.pretty_generate(@config)
    exprex = /\$var\(([^)]+)\)/
    return str.scan(exprex).flatten.uniq
  end

  def tasks
    @config[:tasks]
  end
  def task_description(task)
    tasks[task.to_sym][:description]
  end
  def publish_header(task)
    tasks[task.to_sym][:publish_header]
  end
  def comparator(task)
    tasks[task.to_sym][:comparator]
  end
  def report(task)
    tasks[task.to_sym][:report]
  end
  def comparator_agregator()
    @config[:comparator_agregator]
  end
  def sources
    @config[:sources]
  end
end
