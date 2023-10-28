module Cat
  def self.cat(task, commit_id, file)
    Helper.validate_commit_id(commit_id)
    Helper.validate_task_exists(task)

    unless commit_id
      status = Status.get_status()
      if status[task.to_sym] != 0
        raise Ex::TaskNotExecutedException
      end
      cmd = "cat #{DirManager.get_persistent_ws_path}/#{task}/#{file}"
      return Helper.return_execute(cmd)
    end

    tmp_dir = DirManager.get_worktree_dir()
    GitManager.create_worktree(commit_id, tmp_dir)

    status = Status.get_status("#{tmp_dir}/status.json")
    if status[task.to_sym] != 0
        raise Ex::TaskNotExecutedException
    end

    cmd = "cat #{tmp_dir}/tasks/#{task}/#{file}"
    to_print = Helper.return_execute(cmd)
    GitManager.remove_worktree(tmp_dir)
    to_print
  end
end
