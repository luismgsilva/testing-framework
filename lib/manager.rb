require_relative './config.rb'
require_relative './directory_manager.rb'
require_relative './git_manager.rb'
require_relative './status_manager.rb'
require_relative './var_manager.rb'
require_relative './build.rb'
require_relative './compare.rb'
require_relative './source.rb'
require 'json'
require 'erb'
require 'git'
module Manager
  
  $PWD = Dir.getwd
  $FRAMEWORK = ".bla"
  
  class Manager
    def initialize(config_file = nil)
      @var_manager = Var_Manager::Var_Manager.new()
      @git_manager = Git_Manager::Git_Manager.new()
      @dir_manager = Directory_Manager::Directory_Manager.new
      @status_manager = Status_Manager::Status_Manager.new()
      @cfg = Config::Config.new(config_file, @var_manager, @dir_manager)
      
      @source = Source::Source.new(@git_manager, @cfg)
    end
    
    def save_config(dir_to)
      @cfg.save_config(dir_to)
    end    
    def clone(repo)
      @git_manager.get_clone_framework(repo)
    end
    def clean()
      @dir_manager.clean_tasks_folder()
    end 

    def compare(arr, isJSON)
      
      compare = Compare::Compare.new

      @git_manager.create_worktree(arr)
      
      dir1 = "#{@git_manager.tmp_dir(0)}/tasks"
      dir2 = "#{@git_manager.tmp_dir(1)}/tasks"
      tasks = (Dir.children(dir1) & Dir.children(dir2)).select { |d| d =~ /_tests/ }
      
      to_execute_commands = {}
      params = @cfg.config[:params]
      tasks.each do |task|
        @cfg.set_params_dependencies(params, task, "#{dir1}/#{task}", "#{dir2}/#{task}")

        data_to_prepare = @cfg.config[:builder][:tasks][task.to_sym][:comparator]
        to_execute = @var_manager.prepare_data(data_to_prepare, params)       
        to_execute_commands.store(task, to_execute)
      end

      if !isJSON
        compare.main(dir1, dir2, to_execute_commands)
      else
        to_execute_commands.each { |task, to_execute| puts "\n #{task}: \n " + `#{to_execute}` }
      end
      
      @git_manager.remove_worktree()    
    end

    def search_log(params)
      @git_manager.search_log(params)
    end

    def publish()
      source_dir = "#{$PWD}/#{$FRAMEWORK}/tasks"
      
      commit_msg_hash = {}
      Dir.children(source_dir).sort.each do |task|
       
        to_execute = @cfg.config[:builder][:tasks][task.to_sym][:publish_header]
        
        params = @cfg.config[:params]
        @cfg.set_params_dependencies(params, task)
        to_execute = @var_manager.prepare_data(to_execute, params)
        
        place_holder = {}
        get_commit_msg(to_execute, place_holder) { |command, config | 
          abort("ERROR: Tools version not found") if !system command + "> /dev/null 2>&1"
          commit_msg = JSON.parse(`#{command}`, symbolize_names: true)
          place_holder.store(commit_msg[:build_name], commit_msg)
        }

        commit_msg_hash.store(task, place_holder)
      end
      @git_manager.publish(JSON.pretty_generate(commit_msg_hash))
    end
   
    def get_commit_msg(to_execute, place_holder) 
      return yield(to_execute, place_holder) if to_execute.class == String
      to_execute.each { |command| yield(command, place_holder) } if to_execute.class == Array
    end

    def internal_git(command)
      @git_manager.internal_git(command)
    end 
    
    def status()  
      abort("ERROR: Nothing built yet") if !system "cat #{@status_manager.path_to_status}"
    end
  
    def var_list()
      @var_manager.var_list(@cfg)
    end
    
    def sources_mg(commands)

      case commands[0]
      when /add/
        @source.add_source(commands[1], commands[2])
      when /get/
        @source.get_source(commands[1])
      when /delete/
        @source.delete_source(commands[1])
      when /remove/
        @source.remove_source(commands[1])
      when /list/
        @source.list_sources()
      when /show/
        @source.show_sources()
      when /pull/
        @source.pull_sources(commands[1])
      when /state/
        @source.state_sources(commands[1])
      else 
        puts "ERROR: Invalid Source Option"
      end
    end


    def log(name_version, isTail)
      path_from = "#{$PWD}/#{$FRAMEWORK}/logs/#{name_version}.log"
      abort("ERROR: Tool not found") if !system (isTail) ? "tail -f #{path_from}" : "cat #{path_from}"
    end
  
    def repo_list()
      @git_manager.get_repo_list()
    end
  
    def build(filter = nil)
      Build::Build.new(@cfg, @git_manager, @dir_manager, @var_manager, @status_manager, filter)
    end

    def set(str)
      command = str.split('=').first
      path = str.split('=').last
    
      abort("ERROR: not a editable variable") if command =~/[\@]/
      abort("ERROR: #{command} not a variable") if !@var_manager.verify_if_var_exists(@cfg.config, command)
    
      params = @cfg.config[:params]
      params.store(command.to_sym, "#{path}")
      @cfg.config.store(:params, params)
    
      @cfg.set_json()
    end
  
    def help()
      puts <<-EOF
      EOF
    end
  
  end
end
