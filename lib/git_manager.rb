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

    executing("\n#{to_execute.squeeze(" ").strip}")

  end

  def self.search_log(key, value)
    my_lambda = -> (iterate) {
      iterate.each_pair do |k, v|
        return my_lambda.call (v) if v.class == Hash
        if k == key
          return true if v =~ /#{value}/
        end
      end
      return false
    }

    ch_dir = "cd #{DirManager.get_framework_path}"
    branch = `#{ch_dir} ; git branch --show-current`
    `#{ch_dir} ; git rev-list #{branch}`.split.each do |hash|
        header_message = `#{ch_dir} ; git log -n 1 --pretty=format:%s #{hash}`

        find_commit = "#{ch_dir} ; git log #{hash} -n 1"
        if is_valid_json(header_message)
          json = JSON.parse(header_message)
          system(find_commit) if my_lambda.call(json)
        else
          system find_commit if header_message =~ /#{value}/
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

  def self.input_print(str)
    puts str
    input = $stdin.gets.chomp
  end
  def self.internal_git(command)
    command = command.join(" ") if command.class == Array

    if command =~ /commit/
      loop {
        input = input_print("WARNING: This instruction may result in internal conflicts with the commit messages.\nDo you wish to continue? (y/n)")
        break if %w[y yes].any? input
        abort("Process terminated by User.") if %w[n no].any? input
      }
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

    puts "Cloning into '#{path_to_clone}'..."
    puts to_execute
    system (to_execute)
   # return
   # if !system("#{git} > /dev/null 2>&1")
     # abort("ERROR: Something went wrong.") if !system("#{git} > /dev/null 2>&1")
   # end
  end

  def if_already_exists(path_to_clone)
    return File.directory? path_to_clone
  end

  def hard_pull(repo_dir)
    puts "Pulling.."

    executing "cd #{repo_dir} ;
            git reset --hard ;
            git pull --force"
  end

  def self.diff(hash1, hash2)
    hash2 = "HEAD" if hash2.nil?
    to_execute = "cd #{$PWD}/#{$FRAMEWORK} ; diff -w <(git rev-list --max-count=1 --format=%B #{hash1}) <(git rev-list --max-count=1 --format=%B #{hash2})"
    executing(to_execute)

  end

  def check_up_to_date(repo_dir)
    output_exec = `cd #{repo_dir} ;
                  git remote update ;
                  git status -uno`
    puts output_exec

    return output_exec =~ /up\sto\sdate/
  end
end
