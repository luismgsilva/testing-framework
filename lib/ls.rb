module Ls
  def self.ls(task, commit_id)
    Helper.validate_commit_id(commit_id) if commit_id
    Helper.validate_task_exists(task)
  
    unless commit_id
      cmd = "ls #{DirManager.get_persistent_ws_path}/#{task}"
      return Helper.return_execute(cmd)
    end
  
    tmp_dir = DirManager.get_worktree_dir()
    GitManager.internal_git("worktree add #{tmp_dir} #{commit_id} > /dev/null 2>&1")
    cmd = "ls #{tmp_dir}/tasks/#{task}"
    to_print = Helper.return_execute(cmd)
    GitManager.internal_git("worktree remove #{tmp_dir} > /dev/null 2>&1")
    to_print
  end
end