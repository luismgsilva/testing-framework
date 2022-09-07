class GitManager

  attr_reader :name

  def set_git(git_info)
  end

  def valid_repo(repo)
    return system "git ls-remote #{repo} > /dev/null 2>&1"
  end

  def self.executing(to_execute)
    puts "Executing: #{to_execute}"
    return system to_execute
  end

  def to_hard_pull(dir)
    if !check_up_to_date(dir)
      hard_pull(dir)
    end
  end

  def self.publish(commit_msg)
    git_path = "#{DirManager.get_framework_path}/.git"

    create_env() if !DirManager.directory_exists(git_path)

    to_execute = "cd #{DirManager.get_framework_path} ;
                  git add . ;
                  git commit -m '#{commit_msg}'"

    executing(to_execute)
  end



  def self.search_log(search_args)
    my_lambda = -> (iterate, key_search, value_search) {
      iterate.each_pair do |k, v|
        if v.class == Hash
          flag = my_lambda.call(v, key_search, value_search)
          return flag if flag == true
          next
        end
        return my_lambda.call(v, key_search, value_search) if v.class == Hash
        if key_search == k
          return true if v =~ /#{value_search}/
        end
      end
    }
    str = ""
    ch_dir = "cd #{DirManager.get_framework_path}"
    branch = `#{ch_dir} ; git branch --show-current`
    `#{ch_dir} ; git rev-list #{branch}`.split.each do |hash|
        header_message = `#{ch_dir} ; git log -n 1 --pretty=format:%s #{hash}`

        find_commit = "#{ch_dir} ; git log #{hash} -n 1"
        if is_valid_json(header_message)
          flag = []
          json = JSON.parse(header_message)
          search_args.each_pair { |key_search, value_search| flag.append(my_lambda.call(json, key_search, value_search)) }
          system("#{find_commit}") if search_args.length == flag.select { |i| i == true }.length
        else
          system find_commit if header_message =~ /#{value_search}/
        end
    end
  end

  def self.is_valid_json(message)
    begin
      JSON.parse(message)
      return true
    rescue JSON::ParserError => e
      return false
    else
      abort("debug")
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

  def self.get_clone_framework(repo, branch = nil)
    system "git clone " + ((branch.nil?) ? "" : " --branch #{branch} ") + " #{repo} #{DirManager.get_framework_path}"
  end

  def self.create_worktree(baseline, reference, dir1, dir2)
    reference = "HEAD" if reference.nil?

    internal_git("worktree add #{dir1} #{baseline} > /dev/null 2>&1")
    internal_git("worktree add #{dir2} #{reference} > /dev/null 2>&1")
  end

  def self.remove_worktree(dir1, dir2)
    internal_git("worktree remove #{dir1}")
    internal_git("worktree remove #{dir2}")
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

  # DEPRECATED
#  def hard_pull(repo_dir)
#    puts "Pulling.."
#
#    executing "cd #{repo_dir} ;
#            git reset --hard ;
#            git pull --force"
#  end

  # Nonfunctioning
  def self.diff(hash1, hash2)
    hash2 = "HEAD" if hash2.nil?
    to_execute = "cd #{$PWD}/#{$FRAMEWORK} ; diff -w <(git rev-list --max-count=1 --format=%B #{hash1}) <(git rev-list --max-count=1 --format=%B #{hash2})"
    executing(to_execute)
  end

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
