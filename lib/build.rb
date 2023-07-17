class Build

  def self.filter_task(data, selected_tasks)
    selected_tasks.map! &:to_sym
    res =  selected_tasks - data.keys
    if res
      raise Ex::InvalidOptionException(res[0])
    end
    return data.slice(*selected_tasks)
  end

  def self.pre_condition(data, skip)
    failed_tasks = {}
    data.each_pair do |task, command|
      next if command[:pre_condition].nil?
      Helper.set_internal_vars(task)
      conditions = VarManager.instance.prepare_data(command[:pre_condition])

      out = File.open(DirManager.get_log_file(task), "w")
      Array(conditions).each do |condition|
        system("echo 'BSF Executing: #{condition}' ; #{condition}", out: out, err: out)
        failed_tasks[task] = condition if !$?.success?
      end
    end

    if failed_tasks.any?
      data = data[data.keys - failed_tasks.keys]
      msg = "One or more pre-conditions have failed:\n"
      failed_tasks.each do |task, condition|
        msg += "- #{task}: #{condition}\n"
      end
      raise Ex::API_TEMP.new(msg) if @api
      puts msg
      return if skip
      exit -1 if !data
      Helper.input_user("Do you want to contiue? [y/n]")
    end
  end

  @api = false

  def self.build(selected_tasks, skip, parallel, api = false)
    data = Config.instance.tasks
    data = filter_task(data, selected_tasks) if selected_tasks
    DirManager.create_dir(DirManager.get_logs_path)

    pre_condition(data, skip)
    parallel_verifier(data, parallel)
  end

  def self.execute(task, command)
    Helper.set_internal_vars(task)

    to_execute = VarManager.instance.prepare_data(command[:execute])
    workspace_dir = VarManager.instance.get("@WORKSPACE")
    DirManager.create_dir(workspace_dir)
    DirManager.create_dir(VarManager.instance.get("@PERSISTENT_WS"))


    out = File.open(DirManager.get_log_file(task), "w")

    puts "Executing #{task}.."
    status = nil
    Array(to_execute).each do |execute|
      status = system "echo 'BSF Executing: #{execute}' ;
                       cd #{workspace_dir} ;
                       #{execute}", out: out, err: out
      break if !status
    end

    out.close()

    Status.set_status(status, task)
    set_previd(status, task)
  end


  def self.parallel_verifier(data, parallel)
    task_list = []
    data.each do |task, command|
      if parallel
        todo = Thread.new(task) { |this| execute(task, command) }
        task_list << todo
      else
        execute(task, command)
      end
    end
    task_list.each { |task| task.join } if parallel
  end

  def self.set_previd(status, task)
    path = "#{DirManager.get_persistent_ws_path}/#{task}"
    if !system "cd #{path} ; git rev-parse HEAD 2> /dev/null 1> .previd"
      system "echo 'first' > #{path}/.previd"
    end
  end
end
