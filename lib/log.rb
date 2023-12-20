module Log
  def self.log(task, commit_id)
    Helper.validate_task_exists(task)

    if commit_id
      Helper.validate_commit_id(commit_id)
      worktree_dir = DirManager.get_worktree_dir()
      GitManager.remove_worktree(worktree_dir)
      GitManager.create_worktree(commit_id, worktree_dir)
      log_file = DirManager.get_log_file_hash(task)
    else
      log_file = DirManager.get_log_file(task)
    end

    unless File.exists?(log_file)
      raise Ex::TaskNotFoundException.new(task)
    end

    if Flags.instance.get(:follow)
      cmd = "tail -f #{log_file}"
      Helper.execute(cmd)
    else
      cmd = "cat #{log_file}"
      to_print = Helper.return_execute(cmd)
    end

    GitManager.remove_worktree(worktree_dir) if commit_id
    to_print
  end
end
