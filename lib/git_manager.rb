class GitManager

  attr_reader :name

  def set_git(git_info)
  end

  def valid_repo(repo)
    return system "git ls-remote #{repo} > /dev/null 2>&1"
  end

  def self.executing(to_execute)
    return system to_execute
  end


  def self.publish(commit_msg)
    git_path = "#{DirManager.get_framework_path}/.git"

    create_env() if !DirManager.directory_exists(git_path)

    to_execute = "cd #{DirManager.get_framework_path} ;
                  git add . ;
                  git commit -m '#{commit_msg}'"

    Helper.reset_status if executing(to_execute)
    system "rm -rf #{DirManager.get_build_path}/*"
  end


  def self.nested_hash_search(obj, key, value)
    if obj.respond_to?(:key?) && obj.key?(key) && obj[key] =~ /#{value}/
      return true
    elsif obj.respond_to?(:each)
      r = nil
      obj.find { |*a| r = nested_hash_search(a.last, key, value) }
      return r
    end
  end
  def self.search_log(args)
    branch = `cd #{DirManager.get_framework_path} ; git branch --show-current`
    hashs = `cd #{DirManager.get_framework_path} ; git rev-list #{branch}`.split()
    cloned = hashs.clone
    hashs.each do |hash|
      header_msg = `cd #{DirManager.get_framework_path} ; git log -n 1 --pretty=format:%s #{hash}`
      header_msg = JSON.parse(header_msg)
      args.each do |arg|
        arg =~ /(.+)=(.+)/
        cloned.delete(hash) if nested_hash_search(header_msg, $1, $2).nil?
      end
    end

    if !cloned.empty?
      return `cd #{DirManager.get_framework_path} ; git show #{cloned.join(" ")} -q`
    else return "No Matches"
   end
  end

  def self.create_env()
    abort("Must initialize Git Repo: bsf git init")
  end

  def self.internal_git(command)
    command = command.join(" ") if command.class == Array

    begin
      Helper.input_user("WARNING: This instruction may result in internal conflicts with the commit messages.\nDo you wish to continue? [y/n]") if command =~ /commit/ 
    rescue Exception => e
      abort("Process Terminated by User") if e.message == "ProcessTerminatedByUserException"
    end

    to_execute = "cd #{DirManager.get_framework_path} ; git #{command}"
    result = executing(to_execute)
  end

  def self.get_clone_framework(repo, dir)
    DirManager.create_dir("#{dir}")
    system "cd #{dir} ; git clone #{repo} .bsf"
  end

  def self.create_worktree(hash, dir)
    internal_git("worktree add #{dir} #{hash} > /dev/null 2>&1")
  end

  def self.remove_worktree(dir)
    internal_git("worktree remove #{dir} > /dev/null 2>&1")
  end

  def self.get_clone(opts)
    path_to_clone = DirManager.get_source_path(opts[:name])
    return if DirManager.directory_exists(path_to_clone)

    to_execute = "git clone #{opts[:repo]} #{path_to_clone}"
    to_execute += " --branch #{opts[:branch]}" if opts[:branch]
    to_execute += " --depth 1 --single-branch" if opts[:single]

    system (to_execute)
  end

  def if_already_exists(path_to_clone)
    return File.directory? path_to_clone
  end

  def self.diff(hash1, hash2)
    (hash1.keys | hash2.keys).each_with_object({}) do |k, r|
      if hash1[k] != hash2[k]
        if hash1[k].is_a?(Hash) && hash2[k].is_a?(Hash)
          r[k] = diff(hash1[k], hash2[k])
        else
          r[k] = [hash1[k], hash2[k]]
        end
      end
      r
    end
  end
end
