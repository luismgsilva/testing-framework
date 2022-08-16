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
          return data if to_filter.nil?
            
            to_filter.map! { |x| x.to_sym } 
            to_filter.each { |filter| abort ("ERROR: Option Invalid #{filter}") if !data.include? filter }
            data = data.delete_if { |d| !to_filter.include? d }
        end


      def pre_condition(data, params, path_log)
        data_cloned = data.clone
        fails = {}

        data_cloned.each_pair do |task, command|
          next if command[:pre_condition].nil?
          @cfg.set_params_dependencies(params, task)
          to_execute = @var_manager.prepare_data(command[:pre_condition], params)
          
          out = File.open("#{path_log}/#{task}.log", "w")
          to_execute = [to_execute] if to_execute.class == String
          to_execute.each do |execute|
            status = system("echo Executing: #{execute} ; #{execute}", out: out, err: out)
            fails.store(task, execute) and break if !status
          end
        end
        data.keep_if { |k,v| !fails.has_key? k}
          
        data.each_pair { |task, command| puts "Passed Pre-Condition: #{task}" }
        fails.each { |task, command| puts "Failed Pre-Condition: #{task}\n\sInstruction: #{command}" }
        exit -1 if data.empty?
        loop {
          input = -> { puts "Continue? (y/n)" ; $stdin.gets.chomp }.call
          break if %w[y yes].any? input
          abort("Exited by User") if %w[n no].any? input
        } if !fails.empty?
      end
      
        
        def build(to_filter)
            data = @cfg.config[:builder][:tasks]
            params = @cfg.config[:params]
            prefix = params[:PREFIX] 
            log_path = "#{$PWD}/#{$FRAMEWORK}/logs/"
            @dir_manager.create_dir(log_path)
             
            filter_task(data, to_filter)
            pre_condition(data, params, log_path)
            data.each do |task, command|
                prefix_path_to_store = "#{prefix}/#{task}" 
                params.store(:PREFIX, prefix_path_to_store) if !prefix.nil?
                
                @git_manager.set_git(command[:git]) if !command[:git].nil? ##
        

                @cfg.set_params_dependencies(params, task)        

                @dir_manager.delete_build_dir(task) ##
      
                workspace_dir = params[:@WORKSPACE]               
                command.store(:execute, @var_manager.prepare_data(command[:execute], params))
                @dir_manager.create_dir(workspace_dir)
                @git_manager.get_clone() if !command[:git].nil?                
                
                out = File.open("#{log_path}/#{task}.log", "w")
                puts "Executing #{task}.."
                
                to_execute = command[:execute]
                status = nil
                to_execute = [to_execute] if to_execute.class == String
                to_execute.each do |execute|
                  status = system "echo Execution instruction: #{execute} ;
                                  cd #{workspace_dir} ;
                                  #{execute}", out: out, err: out
                  break if !status
                end

                out.close()

                @status_manager.set_status(status, task)
            end
          end
    end
end
