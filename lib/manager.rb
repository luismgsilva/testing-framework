require_relative './config.rb'

require_relative './directory_manager.rb'
require_relative './git_manager.rb'
require_relative './var_manager.rb'
require_relative './build.rb'
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
      abort("Process terminated by User") if e.message == "ProcessTerminatedByUserException" #
    end
    tasks.each { |task| DirManager.clean_tasks_folder(task) }
    Helper.reset_status()
  end

  def tasks_list()
    to_print = ""
    Config.instance.tasks.keys.each do |task|
	    to_print += "#{task}:\n    Description: #{Config.instance.task_description(task)}\n\n"
    end
    return to_print
  end

  def get_commit_data(root, current_commit_id = nil)
    return { prev_commit_id: "first" } if !File.exists? "#{DirManager.get_framework_path}/.git"
    return { prev_commit_id: `cd #{root} ; git rev-parse HEAD`.chomp } if current_commit_id.nil?

    commit_ids = `cd #{root} ; git rev-list --all`.split("\n")
    commit_ids.push("first")
    commit_ids = commit_ids.reverse
    current_commit_id = `cd #{root} ; git rev-parse #{current_commit_id}`.chomp
    previous_commit_id = commit_ids[(commit_ids.find_index(current_commit_id) -1)] || "first"
    return { commit_ids: commit_ids, prev_commit_id: previous_commit_id }
  end

  def report(target, options)
    abort("ERROR: #{target} not in the system") if !Config.instance.tasks.keys.include? target.to_sym
    abort("WARMING: Report not supported") if Config.instance.report(target).nil? #


    commit_id = nil
    if options and options.include? "-h"
      i = options.find_index("-h")
      commit_id = options[i+1]
      options.delete_at(i)
      options.delete_at(i+1)
    end

    to_print = ""
    options = options || ""

    if commit_id
      abort("ERROR: #{commit_id} not valid") if check_commit_id(commit_id)
      dir = DirManager.get_compare_dir(commit_id)
      GitManager.create_worktree(commit_id, dir)
      file = { hash: commit_id, path: dir, }.merge(get_commit_data(dir, commit_id))
    else
      dir = DirManager.get_framework_path()
      file = { hash: "LOCAL", path: dir, }.merge(get_commit_data(dir))
    end

    if !File.exists?("#{dir}/tasks/#{target}/.previd")
      return "no"
    end
    options = options.join(" ") if options.class == Array

    previd = File.read("#{dir}/tasks/#{target}/.previd").chomp
    to_report = previd == file[:prev_commit_id]
    abort("ERROR: Task #{target} not executed") if !to_report
    options += " -h #{file[:path]}/tasks/#{target}:#{file[:hash]}"

    VarManager.instance.set_internal("@OPTIONS", options)
    Helper.set_internal_vars(target)
    commands = Config.instance.report(target)
    to_execute = VarManager.instance.prepare_data(commands)
    to_print = `#{to_execute}`

    GitManager.remove_worktree(file[:path]) if commit_id

    return to_print
  end


  def compare(target, options)
    abort("ERROR: Target not specified") if target.nil?
    abort("ERROR: #{target} not in the system") if !Config.instance.tasks.keys.include? target.to_sym
    # abort("WARMING: Comparator not supported") if Config.instance.comparator(target).nil?
    return "no" if Config.instance.comparator(target).nil?
    to_print = ""
    options = options || ""
    opts = options.clone
    files = {}

    tmp = opts.shift.split(":")
    tmp.each do |hash|
      abort("ERROR: #{hash} not valid") if check_commit_id(hash)
    end

    tmp.each do |hash|
      dir = DirManager.get_compare_dir(hash)
      GitManager.create_worktree(hash, dir)
      files[hash] = { path: dir }.merge(get_commit_data(dir, hash))
    end

    if files.length == 1
      dir = DirManager.get_framework_path()
      files["LOCAL"] = { path: dir, }.merge(get_commit_data(dir))
    end

    opts = opts.join(" ")
    Helper.set_internal_vars(target)
    files.each_pair do |k, v|
      if !File.exists?("#{v[:path]}/tasks/#{target}/.previd")
        opts += " -h :#{k}"
        next
      end
      previd = File.read("#{v[:path]}/tasks/#{target}/.previd").chomp
      to_compare = previd == v[:prev_commit_id]
      opts += (to_compare) ? " -h #{v[:path]}/tasks/#{target}/:#{k}" : " -h :#{k}"
    end
    VarManager.instance.set_internal("@OPTIONS", opts)

    commands = Config.instance.comparator(target)
    to_execute = VarManager.instance.prepare_data(commands)
    to_print = `#{to_execute}`

    files.each_pair do |k, v|
      GitManager.remove_worktree(v[:path])
    end
    return to_print
  end

  def check_commit_id(commit_id)
    return !system("cd #{DirManager.get_framework_path} ; git rev-parse #{commit_id} > /dev/null 2>&1")
  end


  def agregator(options)
    abort("WARMING: Comparator agregator not supported") if Config.instance.comparator_agregator().nil?
    opts = [options[0], "-o", "json"]
    agregator = {}
    Config.instance.tasks.keys.each do |task|
      result = compare(task, opts)
      if result == "no"
        next
      end
      agregator.merge!(JSON.parse(result))

      # agregator.merge!(JSON.parse(compare(task, opts)))
    end

    tmp = options.shift.split(":")
    tmp.push("LOCAL") if tmp.length == 1
    options = options.join(" ")
    tmp.each { |h| options += " -h :#{h}" }

    tmpfile = `mktemp`.chomp
    File.write(tmpfile, JSON.pretty_generate(agregator))
    VarManager.instance.set_internal("@OPTIONS", "#{options}")
    VarManager.instance.set_internal("@AGREGATOR", tmpfile) #

    command = Config.instance.comparator_agregator()
    to_execute = VarManager.instance.prepare_data(command)
    to_print = `#{to_execute}`
  end

  def ls(task, commit_id)
    abort("ERROR: #{commit_id} not valid") if check_commit_id(commit_id)
    abort("ERROR: Task #{task} not found") if !Config.instance.tasks.keys.include? task.to_sym
    return `ls #{DirManager.get_persistent_ws_path}/#{task}` if !commit_id

    tmp_dir = DirManager.get_worktree_dir()
    GitManager.internal_git("worktree add #{tmp_dir} #{commit_id} > /dev/null 2>&1")
    to_print = `ls #{tmp_dir}/tasks/#{task}`
    GitManager.internal_git("worktree remove #{tmp_dir} > /dev/null 2>&1")
    return to_print
  end

  def cat(task, commit_id, file)
    abort("ERROR: #{commit_id} not valid") if check_commit_id(commit_id)
    abort("ERROR: Task #{task} not found") if !Config.instance.tasks.keys.include? task.to_sym
    return `cat #{DirManager.get_persistent_ws_path}/#{task}/#{file}` if !commit_id

    tmp_dir = DirManager.get_worktree_dir()
    GitManager.internal_git("worktree add #{tmp_dir} #{commit_id}")
    to_print = `cat #{tmp_dir}/tasks/#{task}/#{file}`
    GitManager.internal_git("worktree remove #{tmp_dir}")
    return to_print
  end

  def publish()
    persistent_ws = DirManager.get_persistent_ws_path
    commit_msg_hash = {}
    status = JSON.parse(File.read(DirManager.get_status_file))

    Config.instance.tasks.keys.select { |task| status[task.to_s] == 0 }.sort.each do |task|

      to_execute = Config.instance.publish_header(task)
      next if to_execute.nil?
      Helper.set_internal_vars(task)

      to_execute = VarManager.instance.prepare_data(to_execute)
      place_holder = {}
      to_execute = [to_execute] if to_execute.class == String
      to_execute.each do |execute|
        output = `#{execute}`
        abort("ERROR: #{execute}") if !$?.success?
        commit_msg = JSON.parse(output, symbolize_names: true)
        place_holder.merge!(commit_msg)
      end
      
      commit_msg_hash[task] = place_holder
    end
    GitManager.publish(JSON.pretty_generate(commit_msg_hash))
  end

  def internal_git(command)
    GitManager.internal_git(command.join(" "))
  end

  def diff(hash1, hash2)
    abort("ERROR: #{hash1} not valid") if check_commit_id(hash1)
    abort("ERROR: #{hash2} not valid") if check_commit_id(hash2)

    hash1 = JSON.parse(`cd #{DirManager.get_framework_path} ; git log -n 1 --pretty=format:%s #{hash1}`)
    hash2 = JSON.parse(`cd #{DirManager.get_framework_path} ; git log -n 1 --pretty=format:%s #{hash2}`)
    return JSON.pretty_generate GitManager.diff(hash1, hash2)
  end

  def status(commit_id)
    to_print = ""
    mapping = {
      9 => "Not Executed",
      0 => "Passed",
      1 => "Failed"
    }
    begin
      if commit_id
        worktree_dir = DirManager.get_worktree_dir()
        GitManager.internal_git("worktree add #{worktree_dir} #{commit_id}")
        status = Helper.get_status("#{worktree_dir}/status.json")
      else
        status = Helper.get_status
      end
      status.each_pair { |task, result| to_print += "#{mapping[result]}: #{task}\n" }
      GitManager.internal_git("worktree remove #{worktree_dir}") if commit_id
    rescue Exception => e
      abort("ERROR: Nothing executed yet") if e.message == "StatusFileDoesNotExists"
    end
    return to_print
  end

  def log(task, commit_id, is_tail = nil)
    if commit_id
      worktree_dir = DirManager.get_worktree_dir()
      GitManager.internal_git("worktree add #{worktree_dir} #{commit_id}")
      log_file = DirManager.get_log_file_hash(task)
    else
      log_file = DirManager.get_log_file(task)
    end

    abort("ERROR: Tool not found") if !File.exists? log_file
    if is_tail
      system "tail -f #{log_file}"
    else
      to_print = `cat #{log_file}`
    end
    GitManager.internal_git("worktree remove #{worktree_dir}") if commit_id
    return to_print
  end

  def repo_list()
    GitManager.get_repo_list()
  end

  def build(filter = nil, skip_flag = nil, parallel=nil)
    Build.build(filter, skip_flag, parallel)
  end

end
