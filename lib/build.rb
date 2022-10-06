require_relative './helpers.rb'

class Build

  def self.filter_task(data, to_filter)
      return data if to_filter.nil?

      to_filter.map! { |x| x.to_sym }
      to_filter.each { |filter| abort ("ERROR: Option Invalid #{filter}") if !data.include? filter }
      data = data.delete_if { |d| !to_filter.include? d }
  end

  def self.pre_condition(data, skip_flag)
    data_cloned = data.clone
    fails = {}

    data_cloned.each_pair do |task, command|
      next if command[:pre_condition].nil?
      Helper.set_internal_vars(task)
      to_execute = VarManager.instance.prepare_data(command[:pre_condition])

      out = File.open(DirManager.get_log_file(task), "w")
      to_execute = [to_execute] if to_execute.class == String
      to_execute.each do |execute|
        status = system("echo Executing: #{execute} ; #{execute}", out: out, err: out)
        fails.store(task, execute) and break if !status
      end
    end
    data.keep_if { |k,v| !fails.has_key? k}

    data.each_pair { |task, command| puts "Passed Pre-Condition: #{task}" }
    fails.each { |task, command| puts "Failed Pre-Condition: #{task}\n\sInstruction: #{command}" }
    exit -1 if data.empty?
    return if !skip_flag.nil?
    begin
      Helper.input_user("Contiue? [y/n]") if !fails.empty?
    rescue Exception => e
      abort("Process Terminated By User") if e.message == "ProcessTerminatedByUserException"
    end
  end

  def self.build(to_filter, skip_flag)
    data = Config.instance.tasks
    filter_task(data, to_filter)
    DirManager.create_dir(DirManager.get_logs_path)

    pre_condition(data, skip_flag)
    execute(data)
  end

  def self.execute(data)
    data.each do |task, command|
      Helper.set_internal_vars(task)

      to_execute = VarManager.instance.prepare_data(command[:execute])
      workspace_dir = "#{VarManager.instance.get("@WORKSPACE")}/#{task}"
#      workspace_dir = VarManager.instance.get("@WORKSPACE")
      DirManager.create_dir(workspace_dir)

      out = File.open(DirManager.get_log_file(task), "w")
      puts "Executing #{task}.."

#      follow_log_file = "tail -f #{DirManager.get_log_file(task)}"
#      system follow_log_file

      status = nil
      to_execute = [to_execute] if to_execute.class == String
      to_execute.each do |execute|
        status = system "echo 'Execution instruction: #{execute}' ;
                         cd #{workspace_dir} ;
                         #{execute}", out: out, err: out
        break if !status
      end

      out.close()

      Helper.set_status(status, task)
    end
  end
end
