#!/usr/bin/env ruby
module Config

  class Config
    attr_accessor :config
    def initialize(config_source_path = nil, var_manager = nil)
      
      unless config_source_path.nil?
        
        abort("Path must contain config.json file") if !File.exists? "#{config_source_path}/config.json"
        system "mkdir -p #{$SOURCE}/#{$FRAMEWORK}/config_source_path"
        abort("ERROR: Something went wrong..") if !system "cp #{config_source_path}/* #{$SOURCE}/#{$FRAMEWORK}/config_source_path"
        
        file = "#{config_source_path}/config.json" 
        tmp = {} 
        tmp.store(:@CONFIG_SOURCE_PATH, "#{$SOURCE}/#{$FRAMEWORK}/config_source_path")
        file = get_json(file)
        config = {}
        config.store(:params, tmp)
        config.store(:tasks, file)
       
   #     var_manager.check_var_global(config[:builder])
        
        set_json(config)
      else
        @config = get_json()
      end
    end
  
    def get_json(file = "#{$SOURCE}/#{$FRAMEWORK}/config_source_path/config.json")
      return JSON.parse(File.read(file), symbolize_names: true)
    end 
    
   def save_config(path_to_save)
     tmp = @config[:tasks]
     
     system "cp -r #{$SOURCE}/#{$FRAMEWORK}/config_source_path #{path_to_save}"
     File.write("#{path_to_save}/config_source_path/config.json", JSON.pretty_generate(tmp))
   end 

    def set_json(config = @config)
      path = "#{$SOURCE}/#{$FRAMEWORK}/config_source_path"
      system "mkdir #{path}" if !File.directory? "#{path}"
      File.write("#{path}/config.json", JSON.pretty_generate(config))
    end
  end
end
