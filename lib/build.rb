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
  
        def filter_tool(data, to_filter)
            return data if to_filter.empty?
            
            to_filter.map! { |x| x.to_sym } 
        
            to_filter.each { |filter| abort ("ERROR: Option Invalid #{filter}") if !data.include? filter }
            
            tmp = {}
            to_filter.each do |filter|
              tmp.store(filter, data[filter])
              #data.select! { |key| key.eql? filter }
            end
            return tmp
        end

        def pre_conditions_exec(reqs, tool)
          # temporario
          system "mkdir -p #{$SOURCE}/#{$FRAMEWORK}/logs/" if !File.directory? "#{$SOURCE}/#{$FRAMEWORK}/logs/"
          # temporario
          path_test_log = "#{$SOURCE}/#{$FRAMEWORK}/logs/#{tool}.log"
          out = File.open(path_test_log, "w")
          if reqs.class == String
            status = system "echo Execution instruction #{reps} ;
                             #{reps}", out: out, err: out
          elsif reqs.class == Array
            reqs.each do |rep|
              status = system "echo Executing instruction: #{rep} ;
                               #{rep}", out: out, err: out
              return status if !status
            end
          end
          return status
        end 

        def conditions_mg(data, params)
          isPassed = true
          tmp = data.clone
          tmp.each do |tool, command|
            next if command[:pre_condition].nil?
            pre_cond = @var_manager.prepare_data(command[:pre_condition], params) 
            status = pre_conditions_exec(pre_cond, tool)
            data.delete(tool) and isPassed = false if !status
            puts (status) ? "Passed Pre-Condition: #{tool}" : "Failed Pre-Condition: #{tool}"
          end
          return if isPassed
          abort("ERROR: Pre-Conditions not verified") if data.empty?
          input = "n"
          loop do
            puts "Continue? (y/n)\n"
            input =  $stdin.gets.chomp
            break if input == "y" or input == "n"
          end
          abort("Exited by User") if input != "y"
        end
        
        def build(to_filter)
            data = @cfg.config[:builder]
            params = @cfg.config[:params]
            prefix = params[:PREFIX] 
           
            data = filter_tool(data, to_filter)
            conditions_mg(data, params) #
            data.each do |tool, command|
                prefix_path_to_store = "#{prefix}/#{tool}" 
                params.store(:PREFIX, prefix_path_to_store) if !prefix.nil?
                
                @git_manager.set_git(command[:git]) if !command[:git].nil? ##
                
                params.store(:@SOURCE, "#{$SOURCE}/tools/#{@git_manager.name}")
                params.store(:@BUILDNAME, tool.to_s)
                #tmp
                params.store(:@GIT_TESTS, "#{$SOURCE}/#{$FRAMEWORK}/tests/")

                @dir_manager.delete_build_dir(tool) ##

                workspace_dir = "#{$SOURCE}/tools/build/#{tool}" ##                
                params.store(:@WORKSPACE, workspace_dir) #
                #command = @var_manager.prepare_data(command, params)
                command.store(:execute, @var_manager.prepare_data(command[:execute], params))
                @dir_manager.create_directories(tool)
                @git_manager.get_clone() if !command[:git].nil?                
                
                path_make_log = "#{$SOURCE}/#{$FRAMEWORK}/logs/#{tool}.log"
                out = File.open(path_make_log, "w")
                puts "Installing #{tool}.."
                if command[:execute].class == String
                  to_execute = command[:execute]
                  status = system "echo Execution instruction: #{to_execute} ;
                                   cd #{workspace_dir} ;
                                   #{to_execute}", out: out, err: out
                    
                elsif command [:execute].class == Array
                  command[:execute].each do |to_execute|
                    status = system "echo Executing instruction: #{to_execute} ;
                                     cd #{workspace_dir} ; 
                                     #{to_execute}", out: out, err: out  
                  break if !status
                  end
                end
                out.close()

                @status_manager.set_status(status, tool)
            end
          end
          
    end
end
