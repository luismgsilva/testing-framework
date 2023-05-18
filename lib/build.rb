require_relative './helpers.rb'

# Criar json com os problemas do pre-condtion 
# Criar exception costumizadas de forma a guardar esse json para reportar à API

# Criar uma CLI Userinterface
# Criar uma API Userinterface

class Build


  def self.filter_task(data, to_filter)
    to_filter.map! &:to_sym
    res =  to_filter - data.keys
    abort ("ERROR: Option Invalid #{res[0]}") if !res.empty?
    return data.slice(*to_filter)
  end

  # def self.pre_condition(data, skip_flag)
  #   data_cloned = data.clone
  #   str = ""
  #   status = false
  #   data_cloned.each_pair do |task, command|
  #     next if command[:pre_condition].nil?
  #     Helper.set_internal_vars(task)
  #     to_execute = VarManager.instance.prepare_data(command[:pre_condition])

  #     out = File.open(DirManager.get_log_file(task), "w")
  #     to_execute = [to_execute] if to_execute.class == String
  #     placeholder = ""
  #     to_execute.each do |execute|
  #       status = system("echo 'BSF Executing: #{execute}' ; #{execute}", out: out, err: out)
  #       if !status
  #         data.delete(task)
  #         placeholder = execute
  #         break
  #       end
  #     end
  #     str += status ? "Passed Pre-Condition: #{task}\n" :
  #                     "Failed Pre-Condition: #{task}\n\sCommand: #{placeholder}\n"
  #   end
  #   puts str
  #   exit -1 if data.empty?
  #   return if skip_flag
  #   return if str !~ /^Failed/
  #   begin
  #     Helper.input_user("Contiue? [y/n]")
  #   rescue Exception => e
  #     abort("Process Terminated By User") if e.message == "ProcessTerminatedByUserException"
  #   end
  # end



  def self.pre_condition(data, skip_flag)
    # data_cloned = data.clone
    # str = ""
    # status = false
    failed_tasks = []
    # data_cloned.each_pair do |task, command|
    data.each_pair do |task, command|
      next if command[:pre_condition].nil?
      Helper.set_internal_vars(task)
      to_execute = VarManager.instance.prepare_data(command[:pre_condition])

      out = File.open(DirManager.get_log_file(task), "w")
      to_execute = [to_execute] if to_execute.class == String
      # badjoras[task] = []
      # placeholder = ""
      
      to_execute.each do |execute|
        system("echo 'BSF Executing: #{execute}' ; #{execute}", out: out, err: out)
        # badjoras[task] << { condition: execute, status: $?.success? }
        failed_tasks << { task: task, pre_condition: execute } if !$?.success?

        # if !status
        #   data.delete(task)
        #   placeholder = execute
        #   break
        # end
      end


      # str += status ? "Passed Pre-Condition: #{task}\n" :
      #                 "Failed Pre-Condition: #{task}\n\sCommand: #{placeholder}\n"
    end

    if failed_tasks.any?
      data.select! { |task, command| command[:pre_condition].nil? || !failed_tasks.any? { |failed| failed[:task] == task } }
      return if skip_flag
      puts "One or more pre-conditions have failed:"
      failed_tasks.each do |tasks|
        puts "- #{tasks[:task]}: #{tasks[:pre_condition]}"
      end
      exit -1 if data.empty?
      begin
        Helper.input_user("Do you want to contiue? [y/n]")
      rescue Exception => e
        abort("Process Terminated By User") if e.message == "ProcessTerminatedByUserException"
      end
    end


    # puts JSON.pretty_generate badjoras
    # exit
    # puts str
    # exit -1 if data.empty?
    # return if str !~ /^Failed/
    # begin
    #   Helper.input_user("Do you want to contiue? [y/n]")
    # rescue Exception => e
    #   abort("Process Terminated By User") if e.message == "ProcessTerminatedByUserException"
    # end
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

  def self.execute_tmp(task, command)

    Helper.set_internal_vars(task)

    to_execute = VarManager.instance.prepare_data(command[:execute])
    workspace_dir = VarManager.instance.get("@WORKSPACE")
    DirManager.create_dir(workspace_dir)
    DirManager.create_dir(VarManager.instance.get("@PERSISTENT_WS"))

    # out = File.open(DirManager.get_log_file(task), "w")
    file = DirManager.get_log_file(task)
    puts "Executing #{task}.."
    status = nil
    to_execute = [to_execute] if to_execute.class == String
    to_execute.each do |execute|
      status = system "echo 'BSF Executing: #{execute}' | tee -a #{file} &&
                       cd #{workspace_dir} &&
                       sh -c '#{execute}' 2>&1 | tee -a #{file}"
      break if !status
    end

    # out.close()

    Helper.set_status(status, task)
    Helper.set_previd(status, task)

    # Helper.set_internal_vars(task)
    # commands = VarManager.instance.prepare_data(command[:execute])
    # workspace_dir = VarManager.instance.get("@WORKSPACE")
    # DirManager.create_dir(workspace_dir)
    # DirManager.create_dir(VarManager.instance.get("@PERSISTENT_WS"))

    # out = File.open(DirManager.get_log_file(task), "w")
    # puts "Executing #{task}.."
    # commands = [commands] if commands.class == String
    # status = nil
    # begin
    #   commands.each do |command|
    #     bsf_executing = "echo 'BSF Executing: #{command}'"
    #     File.open(DirManager.get_log_file(task), "a") do |file|
    #       file.write(bsf_executing)
    #     end
    #     command = "cd #{workspace_dir} ; #{command}"
    #     IO.popen(command) do |io|
    #       io.each_line do |line|
    #         puts line
    #         File.open(DirManager.get_log_file(task), "a") do |file|
    #           file.write(line)
    #         end
    #       end
    #     end
    #     if $?.exitstatus == 0
    #       status = true
    #     else
    #       status = false
    #       break
    #     end
    #   end
    # rescue Errno::ENOENT => e
    #   puts "Command not found: #{command}"
    #   status = false
    # rescue Errno::EACCES => e
    #   puts "PErmission denied: #{command}"
    #   status = false
    # end

    # out = File.open(DirManager.get_log_file(task), "w")
    # $stdout = Tee.new(STDOUT, out)

    # commands.each do |execute|
    #   `"echo 'BSF Executing: #{execute}' ;
    #                    cd #{workspace_dir} ;
    #                    #{execute}`
    # end

    # out.close()
    # $stdout = STDOUT
    
    # Helper.set_status(status, task)
    # Helper.set_previd(status, task)
  end

  def self.parallel_verifier(data)
    parallel = true
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

# Create a option parser in ruby without any gems that has rules,
# for example a rule would be the command "execute" or "log", it prints 
# the help in case of misstypied any rule. Each rule can contain custom options
# for example "-p" or "-s" and those options only work in relation to the rule executed.

# Each rule may contain a mandatory argument (like the name of a task), a optional 
# argument (Like a '-p' option to work in parallel) or multiple mandatory/optional arguments


# log_file = File.open('log.txt', 'a')
# $stdout.reopen(log_file)
# $stdout.sync = true

# puts "this output goes to both the terminal and log file"
# $stdout.flush


# class Tee
#   def initialize(*targets)
#     @targets = targets
#   end

#   def write(data)
#     @targets.each do |target|
#       target.write(data)
#     end
#   end

#   def close
#     @targets.each(&:close)
#   end
# end