require_relative './exceptions.rb'

class Source

  def self.get_sources_config()
    return Config.instance.sources
  end

  def self.get_sources(input_sources = nil, single)
    input_sources = [input_sources] if input_sources.class == String
    config_sources = get_sources_config
    if input_sources
      input_sources.map! &:to_sym
      if !(input_sources - config_sources.keys).empty?
        raise Ex::NotRegisteredSourceException
      end
      config_sources = config_sources.slice(*input_sources)
    end
    if config_sources.empty?
      raise Ex::NothingToCloneException
    end
    config_sources.each_pair do |k, v|
      source = v
      source[:name] = k
      source[:single] = true if single
      GitManager.get_clone(source)
    end
    GitManager.instance.set_git(get_sources_config[name.to_sym]) 
    GitManager.instance.get_clone
  end

  def self.delete_sources(task)
    source_dir = DirManager.get_source_path(task)
    if !File.directory? source_dir 
      raise Ex::NotRegisteredSourceException
    end
    system "rm -rf #{source_dir}"
  end

  def self.list_sources()
    get_sources_config.each_pair do |source, tmp|
      puts source
      tmp.each { |key, value| puts "   #{key}: #{value}" }
    end
  end

  def self.show_sources()
    if !File.directory? DirManager.get_sources_path
      raise Ex::NoSourcesClonedYetException
    end
    Dir.children("#{$PWD}/sources").sort.each { |source| puts source }
  end

  def self.exists_repo(name)
    return get_sources_config.has_key? name.to_sym
  end
end
