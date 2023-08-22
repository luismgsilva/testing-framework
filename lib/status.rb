module Status

  def self.get_task_status(commit_id = nil)
    mapping = {
      9 => "Not Executed",
      0 => "Passed",
      1 => "Failed"
    }

    if commit_id
      worktree_dir = DirManager.get_worktree_dir()
      GitManager.create_worktree(commit_id, workspace_dir)
      status = get_status("#{worktree_dir}/status.json")
      GitManager.remove_worktree(workspace_dir)
    else
      status = get_status
    end

    status_info = status.map do |task, result|
      result_text = mapping[result]
      "#{result_text}: #{task}"
    end.join("\n")

    return status_info
  end

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
      puts status_path_file
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
    File.write(DirManager.get_status_file, JSON.pretty_generate(status))
  end
end