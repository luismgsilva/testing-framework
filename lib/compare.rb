module Compare

    def compare(target, options)
        validate_target_specified(target)
        validate_target_in_system(target)
    
        return "no" if Config.instance.comparator(target).nil?
    
        to_print = ""
        options ||= ""
        opts = options.clone
        files = {}
    
        validate_commit_ids(opts)
    
        opts.each do |hash|
          dir = DirManager.get_compare_dir(hash)
          GitManager.create_worktree(hash, dir)
          files[hash] = { path: dir }.merge(get_commit_data(dir, hash))
        end
    
        add_local_file(files) if files.length == 1
    
        opts = opts.join(" ")
        Helper.set_internal_vars(target)
    
        opts = build_options(opts, target, files)
    
        VarManager.instance.set_internal("@OPTIONS", opts)
    
        commands = Config.instance.comparator(target)
        to_execute = VarManager.instance.prepare_data(commands)
        to_print = `#{to_execute}`
    
        cleanup_worktrees(files)
    
        return to_print
    end
    



    def add_local_file(files)
        dir = DirManager.get_framework_path()
        files["LOCAL"] = { path: dir }.merge(get_commit_data(dir))
    end
    
    def build_options(options, target, files)
        options.each_pair do |k, v|
        if !File.exists?("#{v[:path]}/tasks/#{target}/.previd")
            options += " -h :#{k}"
            next
        end
        previd = File.read("#{v[:path]}/tasks/#{target}/.previd").chomp
        to_compare = previd == v[:prev_commit_id]
        options += (to_compare) ? " -h #{v[:path]}/tasks/#{target}/:#{k}" : " -h :#{k}"
        end
        options
    end
    
    def get_commit_data(root, current_commit_id = nil)
      if !File.exists? "#{DirManager.get_framework_path}/.git"
        return { prev_commit_id: "first" }
      end
      if current_commit_id.nil?
        return { prev_commit_id: `cd #{root} ; git rev-parse HEAD`.chomp } 
      end

      commit_ids = `cd #{root} ; git rev-list --all`.split("\n")
      commit_ids.push("first")
      commit_ids = commit_ids.reverse
      current_commit_id = `cd #{root} ; git rev-parse #{current_commit_id}`.chomp
      previous_commit_id = commit_ids[(commit_ids.find_index(current_commit_id) -1)] || "first"
      return { commit_ids: commit_ids, prev_commit_id: previous_commit_id }
      end
    
      
      def extract_commit_id(options)
        return nil unless options&.include?("-h")
      
        i = options.index("-h")
        commit_id = options.delete_at(i + 1) if (i + 1) < options.length
        options.delete_at(i)
        commit_id
      end




    def agregator(options)
        if Config.instance.comparator_agregator().nil?
          raise Ex::AgregatorNotSupportedException
        end
    
        opts = [options[0], "-o", "json"]
        agregator = {}
        Config.instance.tasks.keys.each do |task|
          result = compare(task, opts)
          if result == "no"
            next
          end
          agregator.merge!(JSON.parse(result))
        end
    
        tmp = options.shift.split(":")
        tmp.push("LOCAL") if tmp.length == 1
        options = options.join(" ")
        tmp.each { |h| options += " -h :#{h}" }
    
        tmpfile = `mktemp`.chomp
        File.write(tmpfile, JSON.pretty_generate(agregator))
        VarManager.instance.set_internal("@OPTIONS", "#{options}")
        VarManager.instance.set_internal("@AGREGATOR", tmpfile) #
    
        command = Config.instance.comparator_agregator()
        to_execute = VarManager.instance.prepare_data(command)
        to_print = `#{to_execute}`
      end

end
