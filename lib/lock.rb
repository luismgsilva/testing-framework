module Lock

  def self.blocklist(args)
    block_list = [
      "execute", "set", "git",
      "sources", "clean", "publish"
    ]

    if block_list.any? { |arg| args.include?(arg) }
      return false
    else
      return true
    end
  end

  def self.lock(args)
    return if blocklist(args)

    lock_file = DirManager.get_lock_file
    if File.exists?(lock_file)
      cmd = "uptime -s"
      uptime = Helper.return_execute(cmd)

      cmd = "cat #{lock_file}"
      lock_file_content = Helper.return_execute(cmd)

      if uptime == lock_file_content
        raise Ex::CouldNotGetLockException
      end
      unlock(args)
    end

    cmd = "uptime -s > #{lock_file}"
    Helper.execute(cmd)
  end

  def self.unlock(args)
    return if blocklist(args)

    lock_file = DirManager.get_lock_file
    if File.exists?(lock_file)
      cmd = "rm -f #{lock_file}"
      return Helper.execute(cmd)
    end
  end
end
