module Clean

  def self.clean(tasks = nil)
    is_confirm = Flags.instance.get(:confirm)
    is_publish = Flags.instance.get(:publish)

    tasks = tasks || Config.instance.tasks.keys
    Helper.validate_target(tasks)
    unless is_confirm
      msg = "Are you sure you want to clean: [y/n]"
      Helper.input_user(msg, tasks)
    end

    Array(tasks).each do |task|
      puts "Clearing #{task}.." unless is_publish
      DirManager.clean_tasks_folder(task)
      
      Status.reset_status(task)
    end
  end
end
