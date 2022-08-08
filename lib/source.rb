module Source
  class Source
    

    def initialize(git_manager)
      @git_manager = git_manager
    end

    def set_cfg(cfg)
      @cfg = cfg
      @sources = @cfg.config[:builder][:sources]
    end

    def get_source(name)
      abort("ERROR: '#{name}' not a registered Git Repo") if !exists_repo(name) 
      @git_manager.set_git(@sources[name.to_sym]) 
      @git_manager.get_clone 
    end

    def add_source(name, repo, branch = nil)
      abort("ERROR: Git Repo not valid") if !@git_manager.valid_repo(repo)  
      tmp = {}
      tmp.store(:repo, repo)
      tmp.store(:branch, branch) if !branch.nil?
      @sources.store(name, tmp)
      @cfg.set_json()
    end

    def delete_source(name)
      source_dir = "#{$PWD}/sources/#{name}"
      abort("ERROR: '#{name}' not a registered Git Repo") if !File.directory? source_dir 
      system "rm -rf #{source_dir}"
    end
    def remove_source(name)
     # delete_source()
      @sources.delete(name.to_sym)
      @cfg.set_json()
    end
  
    def exists_repo(name)
      return @sources.has_key? name.to_sym

    end
  end
end
