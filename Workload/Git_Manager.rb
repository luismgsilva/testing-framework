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
      @path_to_clone = "#{$SOURCE}/tools/#{@name}"
    end

    def publish()
      env_dir = "#{$SOURCE}/#{$FRAMEWORK}"
      create_env() if !File.directory? "#{env_dir}/.git"
      commit_msg = get_commit_msg("#{$SOURCE}/tools")

      system "cd #{env_dir} ; 
              git add . ;
              git commit -am \"#{commit_msg}\" ;
              git push origin main --force"
    end

    def create_env()
      system "cd #{$SOURCE}/#{$FRAMEWORK} ; 
              git init"
      puts "Must set up Git Repo: ./bla git remote add origin [REPOSITORY]"
      puts "Must set up Branch: .bla git branch -M main"
      exit

    end

    def get_commit_msg(prefix)
      config = {}

      exists = File.directory? "#{prefix}/.git"
      to_execute = "cd #{prefix} ;
                    git log -1 --format=format:\"%H\""
      main_hash = !exists ? nil : `#{to_execute}`

      folders = `cd #{prefix} ; ls -d */`.split "\n"
      folders.map { |str| str.delete_suffix! "/" }

      folders.each do |folder|
        path = "#{prefix}/#{folder}"
        next if !File.directory? "#{path}/.git" 

        hash = `cd #{path} ; 
                git log -1 --format=format:"%H"`

        if File.file? ("#{path}/versions.json")
          file = JSON.parse(File.read("#{path}/versions.json"))
          config.store(folder, file)
        else
          config.store(folder, hash)
        end
      end
      return JSON.pretty_generate(config)

    end

    def internal_git(command)
      result = system "cd #{$SOURCE}/#{$FRAMEWORK} ; 
                       git #{command}"
    end

    def get_clone_framework(repo, branch = 'main')
      path_to_clone = "#{$SOURCE}/.bla"
      system "git clone --branch #{branch} #{repo} #{path_to_clone}"
    end

    def get_clone()

      return if File.directory? (@path_to_clone)

      git = "git clone --branch #{@branch} #{@repo} #{@path_to_clone}"
      puts "Cloning into '#{@path_to_clone}'..."
      if !system("#{git} > /dev/null 2>&1")
        puts "ERROR: Something went wrong." ; exit
      end
    end

    def if_already_exists(path_to_clone)
      return File.directory? @path_to_clone   
    end

    def fetch_repo(path_to_clone)
      if !system("git fetch #{path_to_clone}")
        puts "ERROR: Something went wrong." ; exit
      end
    end

    def check_up_to_date(repo)
      output_exec = `cd #{$SOURCE}/tools/#{repo} ; 
                    git status -uno`
      puts output_exec
    
      return output_exec =~ /up\sto\sdate/
    end

    def get_repo_list()
      repos = Dir.glob("#{$SOURCE}/tools/*/.git")
      repos.map! { |repo| repo.split('/')[-2] }
      repos.each do |repo|
        puts repo + ":"
        #check_up_to_date(repo)
        puts `cd #{$SOURCE}/tools/#{repo} ; 
              git status -uno`.split('.')[0]
      end
    end

    def get_repo_name(repo)
      exprex = /\.git/
      name = repo.split('/').last
      name = name.gsub(exprex, '') if name =~ exprex
      return name
    end
  end
end
