module Ls
  def self.ls(task, commit_id)
    Helper.validate_commit_id(commit_id) if commit_id
    Helper.validate_task_exists(task)

    unless commit_id
      cmd = "ls #{DirManager.get_persistent_ws_path}/#{task}"
      return Helper.return_execute(cmd)
    end

    tmp_dir = DirManager.get_worktree_dir()
    GitManager.create_worktree(commit_id, tmp_dir)
    cmd = "ls #{tmp_dir}/tasks/#{task}"
    to_print = Helper.return_execute(cmd)
    GitManager.remove_worktree(tmp_dir)
    to_print
  end
end