require_relative './exceptions.rb'

class Source

  def self.get_sources_config()
    return Config.instance.sources
  end

  def self.get_sources(input_sources = nil, single)
    input_sources = [input_sources].compact if input_sources.is_a?(String)
    config_sources = get_sources_config

    if input_sources
      input_sources.map! &:to_sym
      invalid_sources = input_sources - config_sources.keys
      unless invalid_sources.empty?
        raise Ex::NotRegisteredSourceException.new(invalid_sources.join(" "))
      end
      config_sources = config_sources.slice(*input_sources)
    end

    raise Ex::NothingToCloneException if config_sources.empty?

    config_sources.each_pair do |name, source|
      source[:name] = name
      source[:single] = true if single
      GitManager.get_clone(source)
    end
  end


  def self.delete_sources(task)
    source_dir = DirManager.get_source_path(task)
    unless File.directory? source_dir
      raise Ex::NotRegisteredSourceException
    end
    cmd = "rm -rf #{source_dir}"
    Helper.execute(cmd)
  end

  def self.list_sources()
    get_sources_config.each_pair do |source, tmp|
      puts source
      tmp.each { |key, value| puts "   #{key}: #{value}" }
    end
  end

  def self.show_sources()
    unless File.directory? DirManager.get_sources_path
      raise Ex::NoSourcesClonedYetException
    end
    Dir.children("#{$PWD}/sources").sort.each { |source| puts source }
  end

  def self.exists_repo(name)
    return get_sources_config.has_key? name.to_sym
  end
end
