require_relative './Config.rb'
require_relative './Directory_Manager.rb'
require_relative './Git_Manager.rb'
require_relative './Status_Manager.rb'
require_relative './Var_Manager.rb'
require 'json'
require 'erb'
require 'git'
module Manager
  
  $SOURCE = Dir.getwd
  $FRAMEWORK = ".bla"
  
  class Manager
    def initialize
      @var_manager = Var_Manager::Var_Manager.new()
      @git_manager = Git_Manager::Git_Manager.new()
      @status_manager = Status_Manager::Status_Manager.new()
    end
    def init(file)
      Config::Config.new(file, @var_manager)
    end
    def clone()
      @git_manager.get_clone_framework()
    end
    def publish()
      @git_manager.publish()
    end
  
    def status(tool)
      if tool.nil?
        status = @status_manager.status
        status.each { |k, v| puts "#{k}: #{v}" }
      else
        status = @status_manager.status[tool.to_sym]
        puts status
      end
    end
  
    def var_list()
      @var_manager.var_list(Config::Config.new)
    end
    def log(name_version)
      begin    
        path_from = "#{$SOURCE}/#{$FRAMEWORK}/logs/#{name_version}/make.log"
        if !system("cat #{path_from}")
          puts "ERROR: Tool not found"
        end
      rescue
        puts "ERROR: Something went wrong...\n"
      end
    end
  
    def repo_list()
      @git_manager.get_repo_list()
    end
  
    def build(filter = nil)
      cfg = Config::Config.new()
      git_manager = Git_Manager::Git_Manager.new()
      dir_manager = Directory_Manager::Directory_Manager.new()
    
      compiler(cfg, git_manager, dir_manager, filter)
    end
  
  
    def set(str)
      cfg = Config::Config.new()
      command = str.split('=').first.downcase
      path = str.split('=').last
    
      if command =~ /[\@]/
        puts 'ERROR: not a editable variable'
        exit
      end
    
      if !@var_manager.verify_if_var_exists(cfg.config[:builder], command)
        puts "ERROR: #{command.upcase} not a variable"
        exit
      end
    
      params = cfg.config[:params]
      params.store(command.to_sym, "#{path}")
      cfg.config.store(:params, params)
    
      cfg.set_json()
    end
  
    def help()
      puts <<-EOF
      EOF
    end
  
    def filter_tool(data, to_filter)
      return data if to_filter.nil?
      to_filter = to_filter.to_sym 
      if !data.include? to_filter
        puts "ERROR: Option Invalid!"
        exit 
      end 
      return data.select! { |key| key.eql? to_filter }
    end
    def to_process(value, key_param, value_param)
      @var_manager.process_var(value, key_param.to_s.upcase, value_param)
    end
  
    def to_each(to_each_var, key_param, value_param)
      tmp = to_each_var
      tmp.each do |key, value|
        to_store_value = (value.class == Hash) ? 
                    to_each(value, key_param, value_param) : 
                    to_process(value, key_param, value_param)
      
        to_each_var.store(key, to_store_value)
      end
    
      to_each_var = tmp
      return to_each_var
    end
  
    def compiler(cfg, git_manager, dir_manager, to_filter)
    
      data = cfg.config[:builder]
      params = cfg.config[:params]
      internal_params = params
      prefix  = internal_params[:prefix]
      version = internal_params[:mod_version]
    
      data = filter_tool(data, to_filter)
      data.each do |tool, command|
        prefix_path_to_store = "#{prefix}/#{tool}/#{version}" 
        internal_params.store(:prefix, prefix_path_to_store) if !prefix.nil?
        prefix = internal_params[:prefix]
      
        git_manager.set_git(command[:git]) 
        internal_params.store(:@SOURCE, "#{$SOURCE}/tools/#{git_manager.name}") 
        dir_manager.delete_build_dir(tool)
        internal_params.each do |key_param, value_param|
          to_each(command, key_param, value_param)
        end
      
        exit if !@var_manager.check_if_set(command)
      
        dir_manager.create_directories(tool, version)
        git_manager.get_clone()
        dir_manager.check_module_file(command[:module_file]) if command.has_key? :module_file
        
        path_make_log = "#{$SOURCE}/#{$FRAMEWORK}/logs/#{tool}/make.log"
    
        out = File.open(path_make_log, 'w')
        puts "Installing #{tool}.."
        status = system "cd #{$SOURCE}/tools/build/#{tool} ; " + 
                         command[:execute], out: out, err: out
        out.close()
        
        if status and command.has_key? :module_file
          dir_manager.create_module_file(prefix, command[:module_file])
        end
        @status_manager.set_status(status, tool)
      end
    end
  end
end
