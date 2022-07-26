require_relative './config.rb'
require_relative './directory_manager.rb'
require_relative './git_manager.rb'
require_relative './status_manager.rb'
require_relative './var_manager.rb'
require_relative './build.rb'
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
    
    def clone(repo)
      @git_manager.get_clone_framework(repo)
    end
    
    def publish()
      @git_manager.publish()
    end
    
    def internal_git(command)
      @git_manager.internal_git(command)
    end 
    
    def status()  
      abort("ERROR: Nothing built yet") if !system "cat #{@status_manager.path_to_status}"
    end
  
    def var_list()
      @var_manager.var_list(Config::Config.new)
    end
    
    def log(name_version)
      path_from = "#{$SOURCE}/#{$FRAMEWORK}/logs/#{name_version}/make.log"
      abort("ERROR: Tool not found") if !system "cat #{path_from}"
    end
  
    def repo_list()
      @git_manager.get_repo_list()
    end
  
    def build(filter = nil)
      cfg = Config::Config.new
      git_manager = Git_Manager::Git_Manager.new
      dir_manager = Directory_Manager::Directory_Manager.new

      Build::Build.new(cfg, git_manager, dir_manager, @var_manager, @status_manager, filter)
    end
    def set(str)
      cfg = Config::Config.new()
      command = str.split('=').first
      path = str.split('=').last
    
      abort("ERROR: not a editable variable") if command =~/[\@]/
      abort("ERROR: #{command} not a variable") if !@var_manager.verify_if_var_exists(cfg.config[:builder], command)
    
      params = cfg.config[:params]
      params.store(command.to_sym, "#{path}")
      cfg.config.store(:params, params)
    
      cfg.set_json()
    end
  
    def help()
      puts <<-EOF
      EOF
    end
  
  end
end
