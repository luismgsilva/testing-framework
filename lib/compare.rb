module Compare

    def self.compare_new(target, options, files, is_agregator = false)
      if is_agregator && Config.instance.comparator(target).nil?
        return
      end

      if files.length == 1
       dir = DirManager.get_framework_path()
       files["LOCAL"] = dir
      end
      files.each_pair do |hash, dir|
        status = Status.get_status("#{dir}/status.json")
        if status[target.to_sym] == 0
          options += " -h #{dir}/tasks/#{target}/:#{hash} "
        else
          options += " -h :#{hash} "
        end
      end

      mutex = Mutex.new
      to_execute = ""

      mutex.synchronize do
        Helper.set_internal_vars(target)
        VarManager.instance.set_internal("@OPTIONS", options)
        commands = Config.instance.comparator(target)
        to_execute = VarManager.instance.prepare_data(commands)
      end
      to_print = Helper.return_execute(to_execute)

      to_print
    end

    def self.compare(target, options)
      Helper.validate_target_specified(target)
      Helper.validate_target_in_system(target)

      if Config.instance.comparator(target).nil?
        raise Ex::ComparatorNotFoundForTargetException
      end


      hashs = options.shift.split(":")
      options = options.join(" ")
      Helper.validate_commit_ids(hashs)
      files = get_files(hashs)
      to_print = compare_new(target, options, files, false)

      Helper.cleanup_worktrees(files)
      to_print
    end

    def self.agregator(options)
      if Config.instance.comparator_agregator().nil?
        raise Ex::AgregatorNotSupportedException
      end

      hashs = options.shift.split(":")
      options = options.join(" ")
      files = get_files(hashs)
      to_print = agregator_new(options, files)

      Helper.cleanup_worktrees(files)
      to_print
    end

    def self.get_files(hashs)
      files = hashs.each_with_object({}) do |hash, result|
        Helper.validate_commit_id(hash)
        dir = DirManager.get_compare_dir(hash)
        GitManager.remove_worktree(dir)
        GitManager.create_worktree(hash, dir)
        result[hash] = dir
      end
    end

    def self.agregator_new(options, files)

      mutex = Mutex.new
      agregator = {}
      threads = []
      Config.instance.tasks.keys.each do |task_|
        task = task_.to_s
        todo = Thread.new(task) { |this|
          comparator_found = compare_new(task, options + " -o json ", files, true)
          next if !comparator_found
          mutex.synchronize do
            agregator.merge!(JSON.parse(comparator_found))
          end
        }
      threads << todo
      end
      threads.each { |task| task.join }

      # Order hash
      sorted = {}
      agregator.keys.sort.each do |key|
        sorted[key] = agregator[key]
      end
      agregator = sorted

      keys = files.keys
      keys.push("LOCAL") if keys.length == 1
      keys.each { |h| options += " -h :#{h} " }

      tmpfile = Helper.return_execute("mktemp").chomp
      File.write(tmpfile, JSON.pretty_generate(agregator))
      VarManager.instance.set_internal("@OPTIONS", "#{options}")
      VarManager.instance.set_internal("@AGREGATOR", tmpfile) #

      command = Config.instance.comparator_agregator()
      to_execute = VarManager.instance.prepare_data(command)
      to_print = Helper.return_execute(to_execute)
    end
end
