module Publish
  def self.publish

    git_path = DirManager.get_git_path
    unless DirManager.directory_exists(git_path)
      raise Ex::MustInitializeGitRepoException
    end

    persistent_ws = DirManager.get_persistent_ws_path
    commit_msg_hash = {}
    status = JSON.parse(File.read(DirManager.get_status_file))

    tasks = Config.instance.tasks.keys
    tasks = tasks.select { |task| status[task.to_s] == 0 }

    if tasks.empty?
      raise Ex::TaskNotExecutedException
    end

    tasks.sort.each do |task|
      to_execute = Config.instance.publish_header(task)
      next unless to_execute

      Helper.set_internal_vars(task)
      to_execute = VarManager.instance.prepare_data(to_execute)
      place_holder = {}

      Array(to_execute).each do |execute|
        output = Helper.return_execute(execute)
        unless $?.success?
          raise Ex::PublishCommandException.new(execute)
        end
        commit_msg = JSON.parse(output, symbolize_names: true)
        place_holder.merge!(commit_msg)
      end

      commit_msg_hash[task] = place_holder
    end

    framework_path = DirManager.get_framework_path

    config_path = DirManager.get_config_path()
    status_file = DirManager.get_status_file()
    persistent_ws_path = DirManager.get_persistent_ws_path()
    log_path = DirManager.get_logs_path()

    store_in = " #{config_path} #{status_file} "
    delete_in = ""
    status = Status.get_status()
    Config.instance.tasks.keys().each do |task|
      if status[task.to_sym] == 0
        store_in  += " #{persistent_ws_path}/#{task} #{log_path}/#{task}.log "
        delete_in += " #{DirManager.get_build_path}/#{task} "
      end
    end

    commit_msg = JSON.pretty_generate(commit_msg_hash)
    cmd = "git -C #{framework_path} add #{store_in} ;
           git -C #{framework_path} commit -m '#{commit_msg}' > /dev/null 2>&1"


    if Helper.execute(cmd)
      Status.reset_status

      unless Flags.instance.get(:ignore)
        # Luis, is it suppose to clean all ws independent if it failed?
        Flags.instance.set(:publish)
        Flags.instance.set(:confirm)
        Clean.clean()
      end
    end
  end
end
