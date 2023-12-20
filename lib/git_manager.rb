require_relative './exceptions.rb'


class GitManager

  attr_reader :name

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
    cmd = "git -C #{DirManager.get_framework_path} branch --show-current"
    branch = Helper.return_execute(cmd)

    cmd = "git -C #{DirManager.get_framework_path} rev-list #{branch}"
    hashs = Helper.return_execute(cmd).split()

    cloned = hashs.clone
    hashs.each do |hash|
      cmd = "git -C #{DirManager.get_framework_path} log -n 1 --pretty=format:%s #{hash}"
      header_msg = JSON.parse(Helper.return_execute(cmd))
      args.each do |arg|
        arg =~ /(.+)=(.+)/
        cloned.delete(hash) if nested_hash_search(header_msg, $1, $2).nil?
      end
    end

    if cloned
      cmd = "git -C #{DirManager.get_framework_path} show #{cloned.join(" ")} -q"
      return Helper.return_execute(cmd)
    else return "No Matches"
   end
  end

  def self.internal_git(command)

    command = command.join(" ") if command.class == Array

    if command =~ /commit/
      msg = "WARNING: This instruction may result in internal conflicts with the commit messages.\nDo you wish to continue? [y/n]"
      Helper.input_user(msg)
    end

    to_execute = "git -C #{DirManager.get_framework_path} #{command}"
    result = Helper.execute(to_execute)
  end

  def self.get_clone_framework(repo, dir)
    DirManager.create_dir("#{dir}")
    cmd = "git -C #{dir} clone #{repo} .bsf"
    Helper.execute(cmd)
  end

  def self.create_worktree(hash, dir)
    internal_git("worktree add -f #{dir} #{hash} > /dev/null 2>&1")
    #internal_git("worktree add -f #{dir} #{hash}")
  end

  def self.remove_worktree(dir)
    internal_git("worktree remove #{dir} > /dev/null 2>&1")
    #internal_git("worktree remove -f #{dir}")
  end

  def self.get_clone(opts)
    path_to_clone = DirManager.get_source_path(opts[:name])
    return if DirManager.directory_exists(path_to_clone)

    to_execute = "git clone #{opts[:repo]} #{path_to_clone}"
    to_execute += " --branch #{opts[:branch]}" if opts[:branch]
    to_execute += " --depth 1 --single-branch" if opts[:single]

    Helper.execute(to_execute)
  end
end
