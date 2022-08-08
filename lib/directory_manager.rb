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
      path = "#{$PWD}/tools/build/#{repo_name}"
      system "rm -rf #{path}" if File.directory? path
    end
  
    def create_directories(name)
      paths = ["#{$PWD}/tools/build/#{name}",
               "#{$PWD}/.bla/logs/#{name}" #,
              # "#{$PWD}/.bla/tests/"
      ]
      paths.each { |path| create_dir(path) }
    end
  
    def check_module_file module_file
      module_template = module_file[:template]
      abort("ERROR: Module template file not found: #{module_template}") if !File.exists? module_template
    end
    
=begin 
    def create_module_file(prefix, tool, module_file)
      
      module_prefix = module_file[:prefix]
      module_template = module_file[:template]
      version = module_file[:version]
      
      module_dir = "#{module_prefix}/#{tool}/"
      create_dir(module_dir)
       
      template = ERB.new(File.read(module_template))
      File.write("#{module_dir}/#{version}.lua", template.result(binding))
    end
=end
  end
end
