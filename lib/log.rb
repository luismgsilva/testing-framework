module Log
  def log(task, commit_id, is_tail = nil)
    if commit_id
      worktree_dir = DirManager.get_worktree_dir()
      GitManager.internal_git("worktree add #{worktree_dir} #{commit_id}")
      log_file = DirManager.get_log_file_hash(task)
    else
      log_file = DirManager.get_log_file(task)
    end
  
    unless File.exists?(log_file)
      raise Ex::TaskNotFoundException
    end 
  
    if is_tail
      cmd = "tail -f #{log_file}"
      Helper.execute(cmd)
    else
      cmd = "cat #{log_file}"
      to_print = Helper.return_execute(cmd)

    end
  
    GitManager.internal_git("worktree remove #{worktree_dir}") if commit_id
    to_print
  end
end