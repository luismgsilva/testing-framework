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

    def get_sources(name = nil)
      to_each = nil
      if !name.nil? 
        name.map! &:to_sym
        config = get_sources_config
        name.each { |n| abort ("ERROR: #{n} not registered Git Repo") if !config.include? n }
        to_each = get_sources_config.delete_if { |cfg| !name.include? cfg }
      elsif name.nil?
        to_each = get_sources_config
      end
      abort("ERROR: Nothing to clone. Try adding a new Source") if to_each.empty?
      to_each.each_pair do |k, v|
        @git_manager.set_git(v) 
        @git_manager.get_clone
      end
      exit
      abort("ERROR: '#{name}' not a registered Git Repo") if !name.nil? and !exists_repo(name) 
      @git_manager.set_git(get_sources_config[name.to_sym]) 
      @git_manager.get_clone 
    end
    
    def edit_sources(name, key, value)
      if_source_not_exists(name)
      config = get_sources_config[name.to_sym]
      abort("ERROR: Key does not exist") if !config.has_key? key
      config[key.to_sym] = value
      @cfg.set_json() 
    end
    
    def if_source_exists(name)
      abort("ERROR: Source already exsits in system") if get_sources_config.has_key? name.to_sym
    end
    
    def if_source_not_exists(name)
      abort("ERROR: Source does not exist in system") if !get_sources_config.has_key? name.to_sym
    end

    def add_sources(name, repo, branch = nil)
      abort("ERROR: Git Repo not valid") if !@git_manager.valid_repo(repo)  
      if_source_exists(name)
      tmp = {}
      tmp.store(:repo, repo)
      branch = branch.nil? ? "" : branch
      tmp.store(:branch, branch)
      get_sources_config.store(name, tmp)
      @cfg.set_json()
    end

    def delete_sources(name)
      source_dir = "#{$PWD}/sources/#{name}"
      abort("ERROR: '#{name}' not a registered Git Repo") if !File.directory? source_dir 
      system "rm -rf #{source_dir}"
    end
    def remove_sources(name)
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
