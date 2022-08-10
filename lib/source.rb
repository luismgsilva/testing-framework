module Source
  class Source
    

    def initialize(git_manager, cfg)
      @git_manager = git_manager
      @cfg = cfg
     # puts JSON.pretty_generate @cfg.config
     # exit
     # @sources = @cfg.config[:builder][:sources]
    end
    
    def get_sources_config()
      return @cfg.config[:builder][:sources]
    end

    def get_source(name)
      abort("ERROR: '#{name}' not a registered Git Repo") if !exists_repo(name) 
      @git_manager.set_git(get_sources_config[name.to_sym]) 
      @git_manager.get_clone 
    end

    def add_source(name, repo, branch = nil)
      abort("ERROR: Git Repo not valid") if !@git_manager.valid_repo(repo)  
      tmp = {}
      tmp.store(:repo, repo)
      tmp.store(:branch, branch) if !branch.nil?
      get_sources_config.store(name, tmp)
      @cfg.set_json()
    end

    def delete_source(name)
      source_dir = "#{$PWD}/sources/#{name}"
      abort("ERROR: '#{name}' not a registered Git Repo") if !File.directory? source_dir 
      system "rm -rf #{source_dir}"
    end
    def remove_source(name)
     # delete_source()
      get_sources_config.delete(name.to_sym)
      @cfg.set_json()
    end

    def pull_sources(repo_name)
      abort("ERROR: #{repo_name} not found in sources") if !Dir.children("#{$PWD}/sources").include? repo_name
      @git_manager.to_hard_pull("#{$PWD}/sources/#{repo_name}")
    end

    def state_sources(repo_name)
      abort("ERROR: #{repo_name} not found in sources") if !Dir.children("#{$PWD}/sources").include? repo_name
      @git_manager.check_up_to_date(repo_name)
    end 

    def list_sources()
      get_sources_config.each do |source, tmp|
        puts source 
        tmp.each { |key, value| puts "   #{key}: #{value}" }
      end
    end
    def show_sources()
      abort("ERROR: No sources cloned yet") if !File.directory? "#{$PWD}/sources"
      Dir.children("#{$PWD}/sources").sort.each { |source| puts source }
    end
    def exists_repo(name)
      return get_sources_config.has_key? name.to_sym
    end
  end
end
