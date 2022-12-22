require_relative './helpers.rb'

class Build


  def self.filter_task(data, to_filter)
    to_filter.map! &:to_sym
    res =  to_filter - data.keys
    abort ("ERROR: Option Invalid #{res[0]}") if !res.empty?
    return data.slice(*to_filter)
  end

  def self.pre_condition(data, skip_flag)
    data_cloned = data.clone
    str = ""
    status = false
    data_cloned.each_pair do |task, command|
      next if command[:pre_condition].nil?
      Helper.set_internal_vars(task)
      to_execute = VarManager.instance.prepare_data(command[:pre_condition])

      out = File.open(DirManager.get_log_file(task), "w")
      to_execute = [to_execute] if to_execute.class == String
      placeholder = ""
      to_execute.each do |execute|
        status = system("echo 'BSF Executing: #{execute}' ; #{execute}", out: out, err: out)
        if !status
          data.delete(task)
          placeholder = execute
          break
        end
      end
      str += status ? "Passed Pre-Condition: #{task}\n" :
                      "Failed Pre-Condition: #{task}\n\sCommand: #{placeholder}\n"
    end
    puts str
    exit -1 if data.empty?
    return if skip_flag
    return if str !~ /^Failed/
    begin
      Helper.input_user("Contiue? [y/n]")
    rescue Exception => e
      abort("Process Terminated By User") if e.message == "ProcessTerminatedByUserException"
    end
  end

  def self.build(to_filter, skip_flag)
    data = Config.instance.tasks
    data = filter_task(data, to_filter) if to_filter
    DirManager.create_dir(DirManager.get_logs_path)

    pre_condition(data, skip_flag)
    parallel_verifier(data)
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

  def self.parallel_verifier(data)
    parallel = false
    task_list = []
    data.each do |task, command|
      if parallel
        todo = Thread.new(task) { |this| tmp(task, command) }
        task_list << todo
      else
        tmp(task, command)
      end
    end

    task_list.each { |task| task.join } if parallel
  end
end
