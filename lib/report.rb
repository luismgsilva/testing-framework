module Report

  def report(target, options)
    validate_target(target)
    validate_report_support(target)
  
    commit_id = extract_commit_id(options)
  
    file = if commit_id
      validate_commit_id(commit_id)
      dir = DirManager.get_compare_dir(commit_id)
      GitManager.create_worktree(commit_id, dir)
      { hash: commit_id, path: dir }.merge(get_commit_data(dir, commit_id))
    else
      dir = DirManager.get_framework_path()
      { hash: "LOCAL", path: dir }.merge(get_commit_data(dir))
    end
  
    # why?
    #return "no" unless File.exists?("#{file[:path]}/tasks/#{target}/.previd")
  
    options = normalize_options(options)
    validate_task_execution(file, target)
  
    options += " -h #{file[:path]}/tasks/#{target}:#{file[:hash]}"
    VarManager.instance.set_internal("@OPTIONS", options)
    Helper.set_internal_vars(target)
    commands = Config.instance.report(target)
    to_execute = VarManager.instance.prepare_data(commands)
    to_print = `#{to_execute}`
  
    GitManager.remove_worktree(file[:path]) if commit_id
  
    return to_print
  end

  def normalize_options(options)
    options ||= ""
    options.join(" ") if options.class == Array
  end
end