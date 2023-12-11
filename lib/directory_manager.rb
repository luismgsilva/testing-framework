module DirManager

  FRAMEWORK = ".bsf"

  def self.change_directory(path)
    Dir.chdir(path)
  end
  def self.pwd
    Dir.getwd()
  end
  def self.make_absolute_path(path)
    if File.absolute_path?(path)
      return path
    else
      return File.expand_path(path)
    end
  end
  def self.get_config_path
    "#{pwd}/#{FRAMEWORK}/.config"
  end
  def self.get_framework_path
    "#{pwd}/#{FRAMEWORK}"
  end
  def self.get_git_path
    "#{pwd}/#{FRAMEWORK}/.git"
  end
  def self.get_build_path(task = "")
    "#{pwd}/workspace/#{task}"
  end
  def self.get_sources_path
    "#{pwd}/sources"
  end
  def self.get_source_path(source)
    "#{get_sources_path}/#{source}"
  end
  def self.get_lock_file
    "#{Dir.getwd}/.lock"
  end
  def self.get_persistent_ws_path(task = "")
    # "#{get_framework_path}/persistent_ws/#{task}"
    "#{get_framework_path}/tasks/#{task}"
  end
  def self.get_logs_path
    "#{get_framework_path}/logs"
  end
  def self.get_log_file(file)
    "#{get_logs_path}/#{file}.log"
  end
  def self.get_log_file_hash(file)
    "#{get_worktree_dir}/logs/#{file}.log"
  end
  def self.get_status_file
    "#{get_framework_path}/status.json"
  end
  def self.get_vars_file
    "#{get_config_path}/vars.json"
  end
  def self.create_dir_for_file(file)
    create_dir(File.dirname(file))
  end
  def self.create_dir(dir)
    Helper.execute("mkdir -p #{dir}") unless File.directory? dir
  end
  def self.copy_folder(dir_from, dir_to)
    Helper.execute("cp -r #{dir_from} #{dir_to}")
  end
  def self.copy_file(file_from, file_to)
    Helper.execute("cp #{file_from} #{file_to}")
  end
  def self.clean_tasks_folder(task)
    Helper.execute("rm -rf #{get_build_path}/#{task} #{get_logs_path}/*")
  end

  def self.get_worktree_dir()
    dir = "#{get_build_path}/worktree"
    create_dir(dir)
    return dir
  end

  def self.get_compare_dir(index)
    dir = "#{get_build_path}/compare/#{index}"
    create_dir(dir)
    return dir
  end
  
  def self.directory_exists(dir)
    File.directory? (dir)
  end
  def self.file_exists(file)
    File.exists? (file)
  end
  def self.intersect_children_path(dir1, dir2)
    (Dir.children(dir1) & Dir.children(dir2))
  end
end
