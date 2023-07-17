module Clean

  def clean(tasks = nil, skip_flag = nil)
    tasks = Config.instance.tasks.keys if tasks.nil?
    # tasks = [tasks] if tasks.class == String
    if skip_flag.nil?
      msg = "Are you sure you want to clean: [y/n]"
      Helper.input_user(msg, tasks)
    end

    Array(tasks).each do |task|
      DirManager.clean_tasks_folder(task)
      Helper.reset_status(task)
    end
    # Array(tasks).each { |task| DirManager.clean_tasks_folder(task) }
    # if tasks
      
    # else
      # Helper.reset_status()
    # end
  end
end