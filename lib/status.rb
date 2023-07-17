module Status

  # def status(commit_id)
  #   to_print = ""
  #   mapping = {
  #     9 => "Not Executed",
  #     0 => "Passed",
  #     1 => "Failed"
  #   }
  #   if commit_id
  #     worktree_dir = DirManager.get_worktree_dir()
  #     GitManager.internal_git("worktree add #{worktree_dir} #{commit_id}")
  #     status = Helper.get_status("#{worktree_dir}/status.json")
  #   else
  #     status = Helper.get_status
  #   end
  #   status.each_pair { |task, result| to_print += "#{mapping[result]}: #{task}\n" }
  #   GitManager.internal_git("worktree remove #{worktree_dir}") if commit_id
  #   return to_print
  # end



  def get_task_status(commit_id = nil)
    mapping = {
      9 => "Not Executed",
      0 => "Passed",
      1 => "Failed"
    }
  
    if commit_id
      worktree_dir = DirManager.get_worktree_dir()
      GitManager.create_worktree(commit_id, workspace_dir)
      status = Helper.get_status("#{worktree_dir}/status.json")
      GitManager.remove_worktree(workspace_dir)
    else
      status = Helper.get_status
    end
  
    status_info = status.map do |task, result|
      result_text = status_mapping[result]
      "#{result_text}: #{task}"
    end.join("\n")

    return status_info
  end


  # def self.set_status(result, task)
  #   data = "{}"
  #   file = DirManager.get_status_file
  #   data = File.read(file) if(File.exists?(file))
  #   status = JSON.parse(data, symbolize_names: true)
  #   status[task] = result && 0 || 1
  #   DirManager.create_dir_for_file(file)
  #   File.write(file, JSON.pretty_generate(status))
  #   puts (result) ? "Passed" : "Failed"
  # end
  
  def self.set_status(result, task)
    data = "{}"
    file = DirManager.get_status_file

    if(File.exists?(file))
      File.open(file, "a") do |f|
        f.flock(File::LOCK_EX)
        status = JSON.parse(data, symbolize_names: true)
        status[task] = result && 0 || 1
        DirManager.create_dir_for_file(file)
        f.puts JSON.pretty_generate(status)
      end
    end
    puts (result) ? "Passed" : "Failed"
  end

  def self.get_status(status_path_file = DirManager.get_status_file)
    unless File.exists?(status_path_file)
      raise Ex::StatusFileDoesNotExistsException
    end
    return JSON.parse(File.read(status_path_file))
  end
  def self.reset_status(task = nil)
    status = get_status
    if task
      status[task] = 9
    else
      status.transform_values! { 9 }
    end
    write_status(status)
  end
  # def reset_task_status(task)
  #   Helper.validate_task_exists(task)
  #   status = get_status()
  #   status[task] = 9
  #   write_status(status)
  # end
  def write_status(status)
    File.write(DirManager.get_status_file, JSON.pretty_generate(status))
  end
end