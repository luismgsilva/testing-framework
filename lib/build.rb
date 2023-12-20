class Build

  def self.filter_task(data, selected_tasks)
    selected_tasks.map! &:to_sym
    res =  selected_tasks - data.keys
    if !res.empty?
      raise Ex::InvalidOptionException.new(res[0])
    end
    return data.slice(*selected_tasks)
  end

  def self.pre_condition(data)
    failed_tasks = {}
    data.each_pair do |task, command|
      next if command[:pre_condition].nil?
      Helper.set_internal_vars(task)
      conditions = VarManager.instance.prepare_data(command[:pre_condition])
      out = File.open(DirManager.get_log_file(task), "w")
      Array(conditions).each do |condition|
        status = system("echo 'BSF Executing: #{condition}' ; #{condition}", out: out, err: out)
        if !status
          failed_tasks[task] ||=[]
          failed_tasks[task] << condition
        end
      end
    end

    if failed_tasks.any?
      data = data[data.keys - failed_tasks.keys]
      msg = "One or more pre-conditions have failed:\n"
      failed_tasks.each do |task, conditions|
        msg += "- #{task}:\n"
        conditions.each do |condition|
          msg += "    - #{condition}\n"
        end
      end
      raise Ex::API_TEMP.new(msg) if @api
      puts msg
      return if Flags.instance.get(:confirm)
      exit -1 if !data
      Helper.input_user("Do you want to contiue? [y/n]")
    end
  end

  @api = false

  def self.validate_variables(data)
    data.each do | task, command |
      Helper.set_internal_vars(task)
      VarManager.instance.prepare_data(command[:pre_condition])
      VarManager.instance.prepare_data(command[:execute])
    end
  end

  def self.build(selected_tasks, api = false)
    data = Config.instance.tasks
    data = filter_task(data, selected_tasks) if selected_tasks
    DirManager.create_dir(DirManager.get_logs_path)

    validate_variables(data)
    pre_condition(data)
    parallel_verifier(data)
  end

  def self.execute(task, command)
    is_verbose = Flags.instance.get(:verbose)
    is_ignore  = Flags.instance.get(:ignore)

    mutex = Mutex.new
    mutex.lock
    Helper.set_internal_vars(task)
    steps = VarManager.instance.prepare_data(command[:execute])
    workspace_dir = VarManager.instance.get("@WORKSPACE")
    DirManager.create_dir(workspace_dir)
    DirManager.create_dir(VarManager.instance.get("@PERSISTENT_WS"))
    mutex.unlock

    out = File.open(DirManager.get_log_file(task), "w")

    puts "Executing #{task}.."
    status = nil
    Array(steps).each do |step|
      puts step if is_verbose
      status = system("echo 'BSF Executing: #{step}' ;
                       cd #{workspace_dir} ;
                       #{step}", out: out, err: out)
      break if !status
    end

    out.close()

    Status.set_status(status, task)
  end


  def self.parallel_verifier(data)
    is_parallel = Flags.instance.get(:parallel)

    task_list = []
    data.each do |task, command|
      if is_parallel
        todo = Thread.new(task) { |this| execute(task, command) }
        task_list << todo
      else
        execute(task, command)
      end
    end
    if is_parallel
      task_list.each { |task| task.join }
  end
end

end
