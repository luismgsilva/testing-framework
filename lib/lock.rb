module Lock

  def self.blocklist(args)
    block_list = [
      "execute", "set", "git", 
      "sources", "clean", "publish"
    ]

    if block_list.any? { |arg| args.include?(arg) }
      return true
    else
      return false
    end
  end

  def self.lock(args)
    return if blocklist(args)

    lock_file = DirManager.get_lock_file
    if File.exists?(lock_file)
      if `uptime -s` == `cat #{lock_file}`
        raise Ex::CouldNotGetLockException
      end
      unlock()
    end
  
    system("uptime -s > #{lock_file}")
  end
  
  def self.unlock(args)
    return if blocklist(args)

    lock_file = DirManager.get_lock_file
    if File.exists?(lock_file)
      return system("rm -rf #{lock_file}")
    end
  end
end