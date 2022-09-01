class Source

  def self.get_sources_config()
    return Config.instance.sources
  end

  def self.get_sources(name = nil)
    begin
      
      to_each = nil
      if !name.nil? 
        name.map! &:to_sym
        config = get_sources_config
        name.each { |n| raise("NotRegisteredSourceException") if !config.include? n }
        to_each = get_sources_config.delete_if { |cfg| !name.include? cfg }
      elsif name.nil?
        to_each = get_sources_config
      end
      
      raise("NothingToCloneException") if to_each.empty?
      
      to_each.each_pair do |k, v|
        opts = v
        opts[:name] = k
        GitManager.get_clone(opts)
      end
      
      raise("NotRegisteredSourceExcetpion") if !name.nil? and !exists_repo(name) 
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

  def self.pull_sources(source)
    begin
      raise("NotFoundInSourcesException") if !Dir.children(DirManager.get_sources_path).include? source
      GitManager.instance.to_hard_pull(DirManager.get_source_path(source))
    rescue Exception => e
      abort("ERROR: #{source} not found in Sources") if e.message == "NotFoundInSourcesException"
    end
  end

  def self.state_sources(source)
    begin
      raise "NotFoundInSourcesException" if !Dir.children(DirManager.get_sources_path).include? source
      GitManager.instance.check_up_to_date(source)
    rescue Exception => e
      abort("ERROR: #{repo_name} not found in sources") if e.message == "NotFoundInSourcesException"
    end
  end 

  def self.list_sources()
    get_sources_config.each do |source, tmp|
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
