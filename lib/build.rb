require_relative './helpers.rb'
require_relative './exceptions.rb'

class Build

  def self.filter_task(data, to_filter)
    to_filter.map! &:to_sym
    res =  to_filter - data.keys
    if !res.empty?
      raise Ex::InvalidOptionException(res[0])
    end
    return data.slice(*to_filter)
  end

  def self.pre_condition(data, skip_flag)
    failed_tasks = []
    data.each_pair do |task, command|
      next if command[:pre_condition].nil?
      Helper.set_internal_vars(task)
      to_execute = VarManager.instance.prepare_data(command[:pre_condition])

      out = File.open(DirManager.get_log_file(task), "w")
      to_execute = [to_execute] if to_execute.class == String
      to_execute.each do |execute|
        system("echo 'BSF Executing: #{execute}' ; #{execute}", out: out, err: out)
        failed_tasks << { task: task, pre_condition: execute } if !$?.success?
      end
    end

    if failed_tasks.any?
      data.select! { |task, command| command[:pre_condition].nil? || !failed_tasks.any? { |failed| failed[:task] == task } }
      return if skip_flag
      puts "One or more pre-conditions have failed:"
      failed_tasks.each do |tasks|
        puts "- #{tasks[:task]}: #{tasks[:pre_condition]}"
      end
      exit -1 if data.empty?
      Helper.input_user("Do you want to contiue? [y/n]")
    end
  end

  def self.build(to_filter, skip_flag, parallel)
    data = Config.instance.tasks
    data = filter_task(data, to_filter) if to_filter
    DirManager.create_dir(DirManager.get_logs_path)

    pre_condition(data, skip_flag)
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
    to_execute = [to_execute] if to_execute.class == String
    to_execute.each do |execute|
      status = system "echo 'BSF Executing: #{execute}' ;
                       cd #{workspace_dir} ;
                       #{execute}", out: out, err: out
      break if !status
    end

    out.close()

    Helper.set_status(status, task)
    Helper.set_previd(status, task)
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
end
