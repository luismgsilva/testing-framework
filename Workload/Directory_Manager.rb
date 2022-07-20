module Directory_Manager

  class Directory_Manager

    def create_dir(path)
      recursive = path.split('/')
      path = ''
      recursive.each do |dir|
        path += dir + '/'
        system "mkdir #{path}" unless File.directory? (path)
      end
    end
    def delete_build_dir(repo_name)
      path = "#{$SOURCE}/tools/build/#{repo_name}"
      system "rm -rf #{path}" if File.directory? path
    end
  
    def create_directories(name, version)
      paths = ["#{$SOURCE}/tools/build/#{name}",
               "#{$SOURCE}/.bla/logs/#{name}"]
      paths.each { |path| create_dir(path) }
    end
  
    def check_module_file module_file
      module_template = module_file[:template]
      if !File.exists? module_template
        puts "ERROR: Module template file not found: #{module_template}" ; exit
      end
    end
  
    def create_module_file(prefix, module_file)
    
      module_prefix = module_file[:prefix]
      module_template = module_file[:template]
    
      exprex = /\/(.+)\/(.+)\/(.+)$/
      arr = prefix.match(exprex)
      prefix = $1
      name = $2
      version = $3
    
      module_dir = "#{module_prefix}/#{name}/"
      create_dir(module_dir)
    
      template = ERB.new(File.read(module_template))
      File.open("#{module_dir}/#{version}.lua", 'w') do |f|
        f.write template.result(binding)
      end
    end
  end
end
