#!/usr/bin/env ruby
module Config

  class Config
    attr_accessor :config
    def initialize(file = nil, var_manager = nil)
      
      unless file.nil?
        puts file
        tmp = {}
    
          tmp.store(:@PATH, prepare_data(file))
        file = get_json(file)
        config = {}
        config.store(:params, tmp)
        config.store(:builder, file)
       
   #     var_manager.check_var_global(config[:builder])
        
        set_json(config)
      else
        @config = get_json()
      end
    end
  
    def get_json(file = "#{$SOURCE}/#{$FRAMEWORK}/config.json")
      return JSON.parse(File.read(file), symbolize_names: true)
    end 
  

    def prepare_data(file)
      file = file.split("/")
      file.pop
      file = file.join("/")
      return file
    end

    def set_json(config = @config)
      path = "#{$SOURCE}/#{$FRAMEWORK}"
      system "mkdir #{path}" if !File.directory? "#{path}"
      File.write("#{path}/config.json", JSON.pretty_generate(config))
    end
  end
end
