module DirManager

  FRAMEWORK = ".bsf"

  def self.pwd
    Dir.getwd()
  end
  def self.get_config_path
    "#{pwd}/#{FRAMEWORK}/.config"
  end
  def self.get_framework_path
    "#{pwd}/#{FRAMEWORK}"
  end
  def self.get_build_path
    "#{pwd}/workspace"
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
  def self.get_persistent_ws_path
    "#{get_framework_path}/tasks"
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
    system("mkdir -p #{dir}") if !File.directory? dir
  end
  def self.copy_folder(dir_from, dir_to)
    system("cp -r #{dir_from} #{dir_to}")
  end
  def self.copy_file(file_from, file_to)
    puts "aqui"
    system("cp #{file_from} #{file_to}")
  end
  def self.delete_build_dir(repo_name)
    path = "#{get_build_path}/#{repo_name}"
    system "rm -rf #{path}" if File.directory? path
  end
  def self.clean_tasks_folder(task)
    system "echo 'Clearing #{task}..' ;
            rm -rf #{get_build_path}/#{task} ;
            rm -rf #{get_logs_path}/*"

  end

  def self.get_worktree_dir()
    dir = "#{get_build_path}/worktree"
    create_dir(dir)
    return dir
  end

  def self.get_compare_dir()
    dir = "#{get_build_path}/compare/"
    create_dir(dir)
    return "#{dir}/1", "#{dir}/2"
  end
  def self.create_directories(name)
    paths = ["#{Dir.getwd}/build/#{name}",
             "#{Dir.getwd}/#{FRAMEWORK}/logs/" #,
             # "#{Dir.getwd}/.bla/tests/"
    ]
    paths.each { |path| create_dir(path) }
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
