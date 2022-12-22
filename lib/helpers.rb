class Helper

  def self.get_status(status_path_file = DirManager.get_status_file)
    raise("StatusFileDoesNotExists") unless File.exists?(status_path_file)
    return JSON.parse(File.read(status_path_file))
  end
  def self.reset_status()
    r = {}
    Config.instance.tasks.keys.each { |task| r[task] = 9 }
    File.write(DirManager.get_status_file, JSON.pretty_generate(r))
  end
  def self.set_previd(status, task)
    path = "#{DirManager.get_persistent_ws_path}/#{task}"
    if !system "cd #{path} ; git rev-parse HEAD 2> /dev/null 1> .previd"
      system "echo 'first' > #{path}/.previd"
    end
  end

  def self.is_json_valid(msg)
    begin
      JSON.parse(msg)
      return true
    rescue JSON::ParserError => e
      return false
    end
  end
  
  def self.set_status(result, task)
    data = "{}"
    file = DirManager.get_status_file

    if(File.exists?(file))
      File.open(file, "a") do |f|
        f.flock(File::LOCK_EX)
        status = JSON.parse(data, symbolize_names: true)
        status[task] = result && 0 || 1
        DirManager.create_dir_for_file(file)
        f.puts JSON.pretty_generate(status)
      end
    end
    puts (result) ? "Passed" : "Failed"
  end

  def self.set_status(result, task)
    data = "{}"
    file = DirManager.get_status_file
    data = File.read(file) if(File.exists?(file))
    status = JSON.parse(data, symbolize_names: true)
    status[task] = result && 0 || 1
    DirManager.create_dir_for_file(file)
    File.write(file, JSON.pretty_generate(status))
    puts (result) ? "Passed" : "Failed"
  end


  def self.set_internal_vars(task)
    VarManager.instance.set_internal("@SOURCE", "#{DirManager.pwd}/sources")
    VarManager.instance.set_internal("@ROOT", "#{DirManager.pwd}")
    VarManager.instance.set_internal("@BUILDNAME", task.to_s)
    VarManager.instance.set_internal("@PERSISTENT_WS", "#{DirManager.get_persistent_ws_path}/#{task.to_s}")
    VarManager.instance.set_internal("@WORKSPACE", "#{DirManager.get_build_path}/#{task}")
    VarManager.instance.set_internal("@CONFIG_SOURCE_PATH", "#{DirManager.get_framework_path}/.config")
  end

  def self.check_environment(args)
    return if (%w[init clone] & args).any? || args.empty?
    begin
      raise "NotTBSFEnvironmentException" if !File.directory? (DirManager.get_framework_path)
    rescue Exception => e
      abort ("ERROR: Not in a TBSF Environment") if e.message == "NotTBSFEnvironmentException"
    end
  end

  def self.lock_mg(type, args)
    return if !(%w[execute set git sources clean compare publish] & args).any?
    if type == :LOCK
      begin
        lock()
      rescue Exception => e
        abort("WARNING: Could not get Lock") if e.message == "CouldNotGetLockException"
      end
    elsif type == :UNLOCK
      unlock()
    end
  end

  def self.lock
    lock_file = DirManager.get_lock_file
    if File.exists? lock_file
      raise "CouldNotGetLockException" if (`uptime -s` == `cat #{lock_file}`)
      unlock()
    end
    system "uptime -s > #{lock_file}"
  end

  def self.unlock
    lock_file = DirManager.get_lock_file
    return system("rm -rf #{lock_file}") if File.exists? lock_file
  end

  def self.input_user(msg, option = nil)
    puts msg
    puts option if !option.nil?
    loop {
      input = $stdin.gets.chomp
      break if %w[y yes].any? input
      raise "ProcessTerminatedByUserException" if %w[n no].any? input
    }
  end
end
