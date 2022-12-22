class Source

  def self.get_sources_config()
    return Config.instance.sources
  end

  def self.get_sources(input_sources = nil)
    begin
      config_sources = get_sources_config
      if input_sources
        input_sources.map! &:to_sym
        raise("NotRegisteredSourceException") if !(input_sources - config_sources.keys).empty?
        config_sources = config_sources.slice(*input_sources)
      end
      raise("NothingToCloneException") if config_sources.empty?
      
      config_sources.each_pair do |k, v|
        opts = v
        opts[:name] = k
        GitManager.get_clone(opts)
      end

      GitManager.instance.set_git(get_sources_config[name.to_sym]) 
      GitManager.instance.get_clone 
    rescue Exception => e
      abort("ERROR: Nothing to clone.") if e.message == "NothingToCloneException" 
      abort("ERROR: Not a registered Git Repo") if e.message == "NotRegisteredSourceException"
    end
  end

  def self.delete_sources(task)
    begin
      source_dir = DirManager.get_source_path(task)
      raise "NotRegisteredSourceExceptiono" if !File.directory? source_dir 
      system "rm -rf #{source_dir}"
    rescue Exception => e
      abort("ERROR: Not a registered Source") if e.message == "NotRegisteredSourceException"
    end 
  end

  def self.list_sources()
    get_sources_config.each_pair do |source, tmp|
      puts source
      tmp.each { |key, value| puts "   #{key}: #{value}" }
    end
  end

  def self.show_sources()
    begin
      raise "NoSourcesClonedYetException" if !File.directory? DirManager.get_sources_path
      Dir.children("#{$PWD}/sources").sort.each { |source| puts source }
    rescue Exception => e
      abort("ERROR: No sources cloned yet") if e.message == "NoSourcesClonedYetException"
    end
  end

  def self.exists_repo(name)
    return get_sources_config.has_key? name.to_sym
  end
end
