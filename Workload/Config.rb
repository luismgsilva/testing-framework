#!/usr/bin/env ruby
module Config

  class Config
    attr_accessor :config
    def initialize(file = nil, var_manager = nil)
      
      unless file.nil?
        puts file
        file = get_json(file)
        config = {}
        config.store(:params, {})
        config.store(:builder, file)
      
        var_manager.check_var_global(config[:builder])
        set_json(config)
      else
        @config = get_json()
      end
    end
  
    def get_json(file = "#{$SOURCE}/#{$FRAMEWORK}/config.json")
      return JSON.parse(File.read(file), symbolize_names: true)
    end 
  
    def set_json(config = @config)
      path = "#{$SOURCE}/#{$FRAMEWORK}"
      system "cd #{$SOURCE} ; mkdir #{$FRAMEWORK}" if !File.directory? "#{path}"
      File.open("#{path}/config.json", "w") do |f|
        f.write JSON.pretty_generate(config)
      end
    end
  end
end
