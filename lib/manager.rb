require_relative './config.rb'
require_relative './directory_manager.rb'
require_relative './git_manager.rb'
require_relative './var_manager.rb'
require_relative './build.rb'
require_relative './compare.rb'
require_relative './source.rb'
require_relative './helpers.rb'
require 'json'
require 'erb'

$PWD = Dir.getwd

class Manager

  @@instance = nil

  def self.instance
    @@instance = @@instance || Manager.new
    return @@instance
  end
  def initialize()
  end
  
  def save_config(dir_to)
    Config.instance.save_config(dir_to)
  end
  def clone(repo)
    GitManager.get_clone_framework(repo)
  end
  def clean(tasks = nil, skip_flag = nil)
    tasks = Config.instance.tasks.keys if tasks.nil?
    tasks = [tasks] if tasks.class == String
    begin 
      Helper.input_user("Are you sure you want to clean: [y/n]", tasks) if skip_flag.nil?
    rescue Exception => e
      abort("Process terminated by User") if e.message == "ProcessTerminatedByUserException"
    end
    tasks.each { |task| DirManager.clean_tasks_folder(task) }
  end
  def tasks_list()
    puts Config.instance.tasks.keys
  end
  def compare(baseline, reference, options, task)

    options = options || ""
    dir1, dir2 = DirManager.get_compare_dir()
    GitManager.create_worktree(baseline, reference, dir1, dir2)

    dir1 += "/tasks"
    dir2 += "/tasks"
    tasks = DirManager.intersect_children_path(dir1, dir2)
    to_execute_commands = {}

    #
    Helper.set_internal_vars(task)
    VarManager.instance.set_internal("@BASELINE", "#{dir1}/#{task}")
    VarManager.instance.set_internal("@REFERENCE", "#{dir2}/#{task}")
    VarManager.instance.set_internal("@OPTIONS", options) if !options.nil?
    #data_to_prepare = Config.instance.comparator(task)
    commands = Config.instance.comparator(task)
    commands = [commands] if commands.class == String
    commands.each do |data_to_prepare|
      to_execute = VarManager.instance.prepare_data(data_to_prepare)
      puts to_execute
      system to_execute
    end
    dir1, dir2 = DirManager.get_compare_dir()
    GitManager.remove_worktree(dir1, dir2)
  end

  def ls(task, commit_id)
    tmp_dir = DirManager.get_worktree_dir()

    GitManager.internal_git("worktree add #{tmp_dir} #{commit_id} > /dev/null 2>&1")
    system "ls #{tmp_dir}/tasks/#{task}"
    GitManager.internal_git("worktree remove #{tmp_dir} > /dev/null 2>&1")
  end

  def cat(task, commit_id, file)
    tmp_dir = DirManager.get_worktree_dir()

    GitManager.internal_git("worktree add #{tmp_dir} #{commit_id}")
    system("cat #{tmp_dir}/tasks/#{task}/#{file}")
    GitManager.internal_git("worktree remove #{tmp_dir}")
  end

  def publish()
    persistent_ws = DirManager.get_persistent_ws_path
    
    commit_msg_hash = {}
    Dir.children(persistent_ws).sort.each do |task|
      
      to_execute = Config.instance.publish_header(task)
      
      Helper.set_internal_vars(task)

      to_execute = VarManager.instance.prepare_data(to_execute)
      place_holder = {}
      to_execute = [to_execute] if to_execute.class == String
      to_execute.each do |execute|
#        abort("ERROR: Tools version not found") if !system execute + "> /dev/null 2>&1"
        abort("ERROR: Tools version not found") if !system execute
        commit_msg = JSON.parse(`#{execute}`, symbolize_names: true)
        place_holder.store(commit_msg[:build_name], commit_msg)
      end
      
      commit_msg_hash.store(task, place_holder)
      #puts commit_msg_hash
    end
    GitManager.publish(JSON.pretty_generate(commit_msg_hash))
  end

  def get_commit_msg(to_execute, place_holder)
    return yield(to_execute, place_holder) if to_execute.class == String
    to_execute.each { |command| yield(command, place_holder) } if to_execute.class == Array
  end

  def internal_git(command)
    GitManager.internal_git(command.join(" "))
  end

  def diff(hash1, hash2)
    GitManager.diff(hash1, hash2)
  end

  def status()
    begin
      status = Helper.get_status
      status.each_pair do |task, result|
        puts "#{result ? "Passed" : "Failed"}: #{task}"
      end
    rescue Exception => e
      abort("ERROR: Nothing executed yet") if e.message == "StatusFileDoesNotExists"
    end
  end

  def log(task, isTail)
    log_file = DirManager.get_log_file(task)
    puts log_file
    abort("ERROR: Tool not found") if !system (isTail) ? "tail -f #{log_file}" : "cat #{log_file}"
  end

  def repo_list()
    GitManager.get_repo_list()
  end

  def build(filter = nil, skip_flag = nil)
    Build.build(filter, skip_flag)
  end

end
