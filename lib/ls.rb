module Ls
  def ls(task, commit_id)
    validate_commit_id(commit_id) if commit_id
    validate_task_exists(task)
  
    unless commit_id
      return `ls #{DirManager.get_persistent_ws_path}/#{task}`
    end
  
    tmp_dir = DirManager.get_worktree_dir()
    GitManager.internal_git("worktree add #{tmp_dir} #{commit_id} > /dev/null 2>&1")
    to_print = `ls #{tmp_dir}/tasks/#{task}`
    GitManager.internal_git("worktree remove #{tmp_dir} > /dev/null 2>&1")
    to_print
  end

  def validate_commit_id(commit_id)
    raise Ex::CommitIdNotValidException if check_commit_id(commit_id)
  end
    
  def validate_task_exists(task)
    unless Config.instance.tasks.keys.include?(task.to_sym)
      raise Ex::TaskNotFoundException.new(task)
    end
  end
end