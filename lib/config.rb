#!/usr/bin/env ruby
module Config

  class Config
    attr_accessor :config


    def initialize(config_source_path, var_manager, dir_manager)
      
      @var_manager = var_manager
      @dir_manager = dir_manager

      if !config_source_path.nil?
        bla_config_source_path = @dir_manager.get_config_source_path()
        abort("Path must contain config.json file") if !File.exists? "#{config_source_path}/config.json"
        @dir_manager.create_dir(bla_config_source_path)
        abort("ERROR: Something went wrong..") if !@dir_manager.copy_file("#{config_source_path}/*", bla_config_source_path)
        
        config_file = "#{config_source_path}/config.json" 
        params = {}
        config = {}
        params.store(:@CONFIG_SOURCE_PATH, bla_config_source_path)
        config_file = get_json(config_file)
        config.store(:params, params)
        config.store(:builder, config_file)
       
   #     var_manager.check_var_global(config[:builder])
        set_json(config)
      elsif File.directory? "#{@dir_manager.get_config_source_path}"
        @config = get_json()
      end
    end
   
    def set_params_dependencies(params, task, dir1 = nil, dir2 = nil)
      params.store(:@SOURCE, "#{$PWD}/sources")
      params.store(:@BUILDNAME, task.to_s)
      params.store(:@PERSISTENT_WS, "#{$PWD}/#{$FRAMEWORK}/tasks/#{task.to_s}")
      params.store(:@WORKSPACE, "#{$PWD}/build/#{task}")
      params.store(:@BASELINE, dir1) if !dir1.nil?
      params.store(:@REFERENCE, dir2) if !dir2.nil?
    end


    def get_json(file = "#{@dir_manager.get_config_source_path}/config.json")
      return JSON.parse(File.read(file), symbolize_names: true)
    end 
    
   def save_config(dir_to)
     tmp = @config[:builder]
     puts tmp  
     dir_from = @dir_manager.get_config_source_path()
     @dir_manager.create_dir(dir_to)
     @dir_manager.copy_folder(dir_from, dir_to)
     File.write("#{dir_to}/config_source_path/config.json", JSON.pretty_generate(tmp))
   end 

    def set_json(config = @config)
      path = @dir_manager.get_config_source_path
      @dir_manager.create_dir(path)
      File.write("#{path}/config.json", JSON.pretty_generate(config))
    end
  end
end
