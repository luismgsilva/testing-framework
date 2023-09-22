require_relative './exceptions.rb'

class Helper

  def self.is_json_valid(msg)
    begin
      JSON.parse(msg)
      return true
    rescue JSON::ParserError
      return false
    end
  end

  def self.set_internal_vars(task)
    task = task.to_s
    VarManager.instance.set_internal("@SOURCE", DirManager.get_sources_path)
    VarManager.instance.set_internal("@ROOT", DirManager.pwd)
    VarManager.instance.set_internal("@BUILDNAME", task)
    VarManager.instance.set_internal("@PERSISTENT_WS",
      "#{DirManager.get_persistent_ws_path}/#{task}")
    VarManager.instance.set_internal("@WORKSPACE",
      "#{DirManager.get_build_path}/#{task}")
    VarManager.instance.set_internal("@CONFIG_SOURCE_PATH",
      DirManager.get_config_path)
  end

  def self.input_user(message, option = nil)
    puts message
    if option
      puts option
    end
    loop do
      input = $stdin.gets.chomp.downcase

      case input
      when 'y', 'yes'
        break
      when 'n', 'no'
        raise Ex::ProcessTerminatedByUserException
      end
    end
  end

  def self.tasks_list()
    to_print = ""
    Config.instance.tasks.keys.each do |task|
      description = Config.instance.task_description(task)
	    to_print += "#{task}:\n    Description: #{description}\n"
    end
    return to_print
  end


  def self.find_change_directory_arg(args)
    index = args.index("-C")
    if index && index + 1 < args.length
      path = args[index + 1]
      args.delete_at(index + 1)
      args.delete_at(index)
      return path, args
    end
#    nil
    return DirManager.pwd, args
  end

  # ------------

  def self.validate_path(path)
    path = DirManager.make_absolute_path(path)
    if !DirManager.directory_exists(path)
      raise Ex::DirectoryDoesNotExistException.new(path)
    end
  end
  def self.validate_task_execution(file, target)
    previd = File.read("#{file[:path]}/tasks/#{target}/.previd").chomp
    unless previd == file[:prev_commit_id]
      raise Ex::TaskNotExecutedException.new(target)
    end
  end
  def self.validate_commit_id(commit_id)
    if check_commit_id(commit_id)
      raise Ex::CommitIdNotValidException.new(commit_id)
    end
  end
  def self.validate_target(targets)
    Array(targets).each do | target |
      unless Config.instance.tasks.keys.include?(target.to_sym)
        raise Ex::TargetNotInSystemException.new(target)
      end
    end
  end
  def self.validate_report_support(target)
    if Config.instance.report(target).nil?
      raise Ex::ReportNotSupportedException
    end
  end
  def self.validate_commit_ids(options)
    options.each do |hash|
      if check_commit_id(hash)
        raise Ex::CommitIdNotValidException.new(hash)
      end
    end
  end
  def self.check_commit_id(commit_id)
    cmd = "git -C #{DirManager.get_framework_path} rev-parse #{commit_id} > /dev/null 2>&1"
    return !execute(cmd)
  end
  def self.cleanup_worktrees(files)
    files.each_pair do |hash, dir|
      GitManager.remove_worktree(dir)
    end
  end
  def self.validate_target_specified(target)
    unless target
      raise Ex::TargetNotSpecifiedException
    end
  end
  def self.validate_target_in_system(target)
      unless Config.instance.tasks.keys.include?(target.to_sym)
          raise Ex::TargetNotInSystemException.new(target)
      end
  end
  def self.validate_task_exists(task)
    unless Config.instance.tasks.keys.include?(task.to_sym)
      raise Ex::TaskNotFoundException.new(task)
    end
  end

  @debug = false
  def self.execute(cmd)
    puts "DEBUG - BSF Executing: #{cmd}" if @debug
    return system(cmd)
  end
  def self.return_execute(cmd)
    puts "DEBUG - BSF Executing: #{cmd}" if @debug
    return `#{cmd}`
  end
end
