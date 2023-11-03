class Flags

  @@instance = nil

  def initialize
    @flags = {}
  end

  def self.instance
    @@instance = @@instance || self.new
    return @@instance
  end
  
  def set(name, default_value = true)
    @flags[name] = default_value
  end

  def get(name)
    @flags[name]
  end
  
end