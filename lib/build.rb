module Build
    class Build
        def initialize(cfg, git_manager, dir_manager, var_manager, status_manager, to_filter)
            @cfg = cfg
            @git_manager = git_manager
            @dir_manager = dir_manager
            @var_manager = var_manager
            @status_manager = status_manager
            
            build(to_filter)
        end
  
        def filter_task(data, to_filter)
            return data if to_filter.empty?
            
            to_filter.map! { |x| x.to_sym } 
            to_filter.each { |filter| abort ("ERROR: Option Invalid #{filter}") if !data.include? filter }
            data = data.delete_if { |d| !to_filter.include? d }
        end

        def pre_conditions_exec(reqs, task)
          # temporario
          system "mkdir -p #{$PWD}/#{$FRAMEWORK}/logs/" if !File.directory? "#{$PWD}/#{$FRAMEWORK}/logs/"
          # temporario
          path_test_log = "#{$PWD}/#{$FRAMEWORK}/logs/#{task}.log"
          out = File.open(path_test_log, "w")
          status = to_execute_yield(reqs, out) { |reqs, out|
            system "echo Execution instruction #{data} ;
                      #{reqs}", out: out, err: out
            } 
        end

        def to_execute_yield(data, out, dir = nil)
          return yield(data, out, dir) if data.class == String
          status = nil
          data.each { |d| status = yield(d, out, dir) ; break if !status }
          return status
        end

        def conditions_mg(data, params)
          isPassed = true
          tmp = data.clone
          tmp.each do |task, command|
            next if command[:pre_condition].nil?
            pre_cond = @var_manager.prepare_data(command[:pre_condition], params) 
            status = pre_conditions_exec(pre_cond, task)
            data.delete(task) and isPassed = false if !status
            puts (status) ? "Passed Pre-Condition: #{task}" : "Failed Pre-Condition: #{task}"
          end
          return if isPassed
          abort("ERROR: Pre-Conditions not verified") if data.empty?
          loop {
            input = -> { puts "Continue? (y/n)" ; $stdin.gets.chomp }.call
            break if %w[y n yes no].any? input
          }
          abort("Exited by User") if input != "y"
        end
        
        def build(to_filter)
            data = @cfg.config[:tasks]
            params = @cfg.config[:params]
            prefix = params[:PREFIX] 
           
            data = filter_task(data, to_filter)
            conditions_mg(data, params) #
            data.each do |task, command|
                prefix_path_to_store = "#{prefix}/#{task}" 
                params.store(:PREFIX, prefix_path_to_store) if !prefix.nil?
                
                @git_manager.set_git(command[:git]) if !command[:git].nil? ##
                
         #       params.store(:@SOURCE, "#{$PWD}/tools/#{@git_manager.name}")
                
                params.store(:@SOURCE, "#{$PWD}/sources")

                params.store(:@BUILDNAME, task.to_s)
                #tmp
                params.store(:@GIT_TESTS, "#{$PWD}/#{$FRAMEWORK}/tests/")

                @dir_manager.delete_build_dir(task) ##
      
                workspace_dir = "#{$PWD}/tools/build/#{task}" ##                
                params.store(:@WORKSPACE, workspace_dir) #
                #command = @var_manager.prepare_data(command, params)
                command.store(:execute, @var_manager.prepare_data(command[:execute], params))
                @dir_manager.create_directories(task)
                @git_manager.get_clone() if !command[:git].nil?                
                
                path_make_log = "#{$PWD}/#{$FRAMEWORK}/logs/#{task}.log"
                out = File.open(path_make_log, "w")
                puts "Installing #{task}.."
      
                status = to_execute_yield(command[:execute], out, workspace_dir) { |to_execute, out, workspace_dir|
                  system "echo Execution instruction: #{to_execute} ;
                          cd #{workspace_dir} ;
                          #{to_execute}", out: out, err: out
                } 

                out.close()

                @status_manager.set_status(status, task)
            end
          end
          
    end
end
