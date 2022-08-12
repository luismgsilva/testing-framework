module Directory_Manager

  class Directory_Manager

    def get_config_source_path()
      "#{$PWD}/#{$FRAMEWORK}/config_source_path"
    end
    def create_dir(dir)
      system("mkdir -p #{dir}") if !File.directory? dir
    end
    def copy_folder(dir_from, dir_to)
      system("cp -r #{dir_from} #{dir_to}")
    end
    def copy_file(file_from, file_to)
      system("cp #{file_from} #{file_to}")
    end
    def delete_build_dir(repo_name)
      path = "#{$PWD}/build/#{repo_name}"
      system "rm -rf #{path}" if File.directory? path
    end
    def clean_tasks_folder()
      system "echo Clearing Tasks Folder ;
              rm -rf #{$PWD}/#{$FRAMEWORK}/tasks/*"
    end
    def get_compare_dir()
      dir = "#{$PWD}/build/compare/"
      create_dir(dir)
      return "#{dir}/1", "#{dir}/2"
    end
    def create_directories(name)
      paths = ["#{$PWD}/build/#{name}",
               "#{$PWD}/#{$FRAMEWORK}/logs/" #,
              # "#{$PWD}/.bla/tests/"
      ]
      paths.each { |path| create_dir(path) }
    end
  end
end
