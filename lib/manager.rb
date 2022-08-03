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

    def save_config(path_to_save)
      Config::Config.new.save_config(path_to_save)
    end    
    def clone(repo)
      @git_manager.get_clone_framework(repo)
    end
   
    def versions(tool_name)
      cfg = Config::Config.new
      
      internal_params = {}
      internal_params.store(:PREFIX, "#{cfg.config[:params][:PREFIX]}/#{tool_name}")
      to_execute = @var_manager.prepare_data("#{cfg.config[:builder][tool_name.to_sym][:version_check]}", internal_params)
      system "#{to_execute}"
    end 

    # Feito à batatada. vai ser tudo alterado
    def compare(arr)
     
      @git_manager.create_worktree(arr)
      dir_first = "#{@git_manager.tmp_dir(0)}/tests"
      dir_second = "#{@git_manager.tmp_dir(1)}/tests"
      
      folder1 = folder2 = []
      
      `find #{dir_first} -name "*_tests"`.split("\n").each { |s| folder1.append(s.split("/")[-1]) } 
      `find #{dir_second} -name "*_tests"`.split("\n").each { |s| folder2.append(s.split("/")[-1]) } 
      
      tools = folder1 & folder2

      cfg = Config::Config.new

      cfg.config[:params].store(:@BASELINE, "#{@git_manager.tmp_dir(0)}/tests")
      cfg.config[:params].store(:@REFERENCE, "#{@git_manager.tmp_dir(1)}/tests")

      tools.each do |tool|

        cfg.config[:params].store(:@BUILDNAME, tool)
        to_execute = @var_manager.prepare_data("#{cfg.config[:builder][tool.to_sym][:comparator]}", cfg.config[:params])       
        system "gem install terminal-table ; " + to_execute
      
      end
      @git_manager.remove_worktree()    
    end

    def search_log(params)
      @git_manager.search_log(params)
    end


    def publish(tool_name)
      cfg = Config::Config.new
      
      #tmp
      source_dir = "#{$SOURCE}/#{$FRAMEWORK}/tests"
      folders = []
      `find #{source_dir} -name "*_tests"`.split("\n").each { |s| folders.append(s.split("/")[-1]) }     
      p folders
      
      bash_coiso = {} 
      config_tmp = {}
    #  config = cfg.config[:builder][tool_name.to_sym]
      builder = cfg.config[:builder] 
      folders.each do |folder|
        task = cfg.config[:builder][folder.to_sym][:version_check]

     # tmp = config[:version_check]

        if task.class == String
          abort("ERROR: Tools version not found") if !system tmp
          commit_msg = `#{commit_msg}`
        elsif task.class == Array
          config_tmp = {}
          task.each do |command|
            abort("ERROR: Tools version not found") if !system command
            tmp2 = JSON.parse(`#{command}`, symbolize_names: true)
            config_tmp.store(tmp2[:build_name], tmp2)
          end
        end
        bash_coiso.store(folder, config_tmp)
        end
      puts "\n"
      puts JSON.pretty_generate(bash_coiso)

      @git_manager.publish(JSON.pretty_generate(bash_coiso))
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
      path_from = "#{$SOURCE}/#{$FRAMEWORK}/logs/#{name_version}.log"
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
      abort("ERROR: #{command} not a variable") if !@var_manager.verify_if_var_exists(cfg.config, command)
    
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
