class GitManager

  attr_reader :name

  def set_git(git_info)
  end

  def valid_repo(repo)
    return system "git ls-remote #{repo} > /dev/null 2>&1"
  end

  def self.executing(to_execute)
#    puts "Executing: #{to_execute}"
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
   # args = [args]
    branch = `cd #{DirManager.get_framework_path} ; git branch --show-current`
    hashs = `cd #{DirManager.get_framework_path} ; git rev-list #{branch}`.split()
    cloned = hashs.clone
    hashs.each do |hash|
      header_msg = `cd #{DirManager.get_framework_path} ; git log -n 1 --pretty=format:%s #{hash}`
    #  (cloned.delete(hash) and next) if !Helper.is_json_valid(header_msg)
      header_msg = JSON.parse(header_msg)
      args.each do |arg|
        arg =~ /(.+)=(.+)/
        cloned.delete(hash) if nested_hash_search(header_msg, $1, $2).nil?
      end
    end

    if !cloned.empty?
      return `cd #{DirManager.get_framework_path} ; git show #{cloned.join(" ")} -q` if cloned
    else return "No Matches"
   end
  end

#  def self.search_log(search_args)
#    my_lambda = -> (iterate, key_search, value_search) {
#      iterate.each_pair do |k, v|
#        if v.class == Hash
#          flag = my_lambda.call(v, key_search, value_search)
#          return flag if flag == true
#          next
#        end
#        return my_lambda.call(v, key_search, value_search) if v.class == Hash
#        if key_search == k
#          return true if v =~ /#{value_search}/
#        end
#      end
#    }
#    str = ""
#    ch_dir = "cd #{DirManager.get_framework_path}"
#    branch = `#{ch_dir} ; git branch --show-current`
#    `#{ch_dir} ; git rev-list #{branch}`.split.each do |hash|
#        header_message = `#{ch_dir} ; git log -n 1 --pretty=format:%s #{hash}`
#
#        find_commit = "#{ch_dir} ; git log #{hash} -n 1"
#        if is_valid_json(header_message)
#          flag = []
#          json = JSON.parse(header_message)
#          search_args.each_pair { |key_search, value_search| flag.append(my_lambda.call(json, key_search, value_search)) }
#          system("#{find_commit}") if search_args.length == flag.select { |i| i == true }.length
#        else
#          system find_commit if header_message =~ /#{value_search}/
#        end
#    end
#  end

#  def self.is_valid_json(message)
#    begin
#      JSON.parse(message)
#      return true
#    rescue JSON::ParserError => e
#      return false
#    else
#      abort("debug")
#    end
#  end
  
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
    name = opts[:name]
    repo = opts[:repo]
    branch = opts[:branch]
    path_to_clone = DirManager.get_source_path(name)
    
    return if DirManager.directory_exists(path_to_clone)

    is_branch = (branch.nil?) ? "" : "--branch #{branch}"
    to_execute = "git clone #{is_branch} #{repo} #{path_to_clone}"

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
#  def self.diff(hash1, hash2)
#    hash2 = "HEAD" if hash2.nil?
#    to_execute = "cd #{$PWD}/#{$FRAMEWORK} ; diff -w <(git rev-list --max-count=1 --format=%B #{hash1}) <(git rev-list --max-count=1 --format=%B #{hash2})"
#    executing(to_execute)
#  end

  # DEPRECATED
#  def check_up_to_date(repo_dir)
#    output_exec = `cd #{repo_dir} ;
#                  git remote update ;
#                  git status -uno`
#    puts output_exec
#
#    return output_exec =~ /up\sto\sdate/
#  end
end
