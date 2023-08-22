module Cat
  def cat(task, commit_id, file)
    Helper.validate_commit_id(commit_id)
    Helper.validate_task_exists(task)

    unless commit_id
      cmd = "cat #{DirManager.get_persistent_ws_path}/#{task}/#{file}"
      return Helper.return_execute(cmd)
    end

    tmp_dir = DirManager.get_worktree_dir()
    GitManager.internal_git("worktree add #{tmp_dir} #{commit_id}")
    cmd = "cat #{tmp_dir}/tasks/#{task}/#{file}"
    to_print = Helper.return_execute(cmd)
    GitManager.internal_git("worktree remove #{tmp_dir}")
    to_print
  end
end