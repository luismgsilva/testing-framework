module Git_Manager

  class Git_Manager

    attr_reader :name
    def initialize
      #@internal_repo = 'https://github.com/luiss-synopsys/test.git'
    end

    def set_git(git_info)
      @repo = git_info[:repo]
      @branch = git_info[:branch]
      @name = get_repo_name(@repo)
      @path_to_clone = "#{$PWD}/sources/#{@name}"
    end

    def valid_repo(repo)
      return system "git ls-remote #{repo} > /dev/null 2>&1"
    end

    def executing(to_execute)
      puts "Executing: #{to_execute}"
      return system to_execute
    end
      
    def to_hard_pull(dir)
      if !check_up_to_date(dir)
        hard_pull(dir)
      end
    end

    def publish(commit_msg)
      env_dir = "#{$PWD}/#{$FRAMEWORK}"
      
      create_env() if !File.directory? "#{env_dir}/.git"
      
      #if !check_up_to_date(env_dir)
      #  hard_pull(env_dir)
      #end 
       
      to_execute = "cd #{env_dir} ;
                    git add . ;
                    git commit -m '#{commit_msg}'"
               #     git push"    
               # git push -u origin main 
     
      executing("\n#{to_execute.squeeze(" ").strip}")

     # system to_execute
    end
  
    #tmp

    def search_log(params)
      to_execute = "log --all " 
      params.each do |param|
        param = param.split("=")
        to_execute += %{ --grep='"#{param[0]}": "#{param[1]}"'}
      end
      to_execute += " --all-match"
      internal_git(to_execute)
    end


    def create_env()
      puts <<-EOF
      Must initialize Git Repo: bla git init
      Must set up Git Repo: bla git remote add origin [REPOSITIORY]
      Must set up Branch: bla git branch -M main
      EOF
      exit 1

    end
    
    def internal_git(command)
      to_execute = "cd #{$PWD}/#{$FRAMEWORK} ; git #{command}"
      result = executing(to_execute)
     # result = system "cd #{$PWD}/#{$FRAMEWORK} ; 
     #                  git #{command}"
    end

    def get_clone_framework(repo, branch = nil)
      path_to_clone = "#{$PWD}/#{$FRAMEWORK}"
      system "git clone " + ((branch.nil?) ? "" : " --branch #{branch} ") + " #{repo} #{path_to_clone}"
    end
    
    # DELETE THIS
    def delete()
      system "rm -rf #{@path_to_clone}"
    end
    
    def tmp_dir(i)
      "/scratch/luiss/tmp/#{i}"
    end

    def create_worktree(arr, dir1, dir2)
      baseline = arr[0]
      reference = (arr[1].nil?) ? "HEAD" : arr[1]

      internal_git("worktree add #{dir1} #{baseline} > /dev/null 2>&1")
      internal_git("worktree add #{dir2} #{reference} > /dev/null 2>&1")
    end

    def remove_worktree(dir1, dir2)
      internal_git("worktree remove #{dir1}")
      internal_git("worktree remove #{dir2}")
    end

    def get_clone()

      return if File.directory? (@path_to_clone)
      
      git = "git clone " + ((@branch.nil?) ? "" : "--branch #{@branch}") + " #{@repo} #{@path_to_clone}"

      #git = "git clone --branch #{@branch} #{@repo} #{@path_to_clone}"
      puts "Cloning into '#{@path_to_clone}'..."
      
      system (git)
      exit
      if !system("#{git} > /dev/null 2>&1")
        puts "ERROR: Something went wrong." ; exit
      end
    end

    def if_already_exists(path_to_clone)
      return File.directory? @path_to_clone   
    end
    
    def hard_pull(repo_dir)
      puts "Pulling.."

      executing "cd #{repo_dir} ;
              git reset --hard ;
              git pull --force"
    end

=begin
    def fetch_repo(path_to_clone)
      if !system("git fetch #{path_to_clone}")
        puts "ERROR: Something went wrong." ; exit
      end
    end
=end
    def check_up_to_date(repo_dir)
      output_exec = `cd #{repo_dir} ; 
                    git remote update ; 
                    git status -uno`
      puts output_exec
    
      return output_exec =~ /up\sto\sdate/
    end
=begin
    def get_repo_list()
      repos = Dir.glob("#{$PWD}/sources/*/.git")
      repos.map! { |repo| repo.split('/')[-2] }
      repos.each do |repo|
        puts repo + ":"
        #check_up_to_date(repo)
        puts `cd #{$PWD}/sources#{repo} ; 
              git status -uno`.split('.')[0]
      end
    end
=end
    def get_repo_name(repo)
      exprex = /\.git/
      name = repo.split('/').last
      name = name.gsub(exprex, '') if name =~ exprex
      return name
    end
  end
end
