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


    def search_log(key, value)
      my_lambda = -> (iterate) {
        iterate.each_pair do |k, v|
          return my_lambda.call (v) if v.class == Hash
          if k == key
            return true if v =~ /#{value}/
          end
        end
        return false
      }

      ch_dir = "cd #{$FRAMEWORK}"
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

    def is_valid_json(message)
      begin 
        JSON.parse(message)
        return true
      rescue JSON::ParserError => e
        return false
      else 
        abort("debug")
      end
    end   
=begin
    def search_log(key, value)
      my_lambda = -> (iterate) { 
        iterate.each_pair do |k, v|
          return my_lambda.call (v) if v.class == Hash
          if k == key
            return true if v =~ /#{value}/
          end
        end
        return false
      }
      ch_dir = "cd #{$FRAMEWORK}"
      branch = `#{ch_dir} ; git branch --show-current`
      `#{ch_dir} ; git rev-list #{branch}`.split.each do |hash|
        begin 
          json = JSON.parse(`#{ch_dir} ; git log -n 1 --pretty=format:%s #{hash}`)
        rescue => a
          next
        end
        system "#{ch_dir} ; git log #{hash} -n 1" if my_lambda.call(json)
      end
    end
=end
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

    def create_worktree(baseline, reference, dir1, dir2)
      reference = "HEAD" if reference.nil?

      internal_git("worktree add #{dir1} #{baseline} > /dev/null 2>&1")
      internal_git("worktree add #{dir2} #{reference} > /dev/null 2>&1")
    end

    def remove_worktree(dir1, dir2)
      internal_git("worktree remove #{dir1}")
      internal_git("worktree remove #{dir2}")
    end



    def get_clone()#repo, path_to_clone, branch = nil)

      return if File.directory? (@path_to_clone)
      
      git = "git clone " + ((@branch.nil?) ? "" : "--branch #{@branch}") + " #{@repo} #{@path_to_clone}"

      puts "Cloning into '#{@path_to_clone}'..."
      
     # system (git)
     # return
     # if !system("#{git} > /dev/null 2>&1")
        abort("ERROR: Something went wrong.") if !system("#{git} > /dev/null 2>&1")
     # end
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
