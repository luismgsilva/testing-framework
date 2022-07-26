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
            return data if to_filter.nil?
            to_filter = to_filter.to_sym 
            abort("ERROR: Option Invalid #{to_filter}") if !data.include? to_filter
            return data.select! { |key| key.eql? to_filter }
        end

        def to_process(value, key_param, value_param)
            @var_manager.process_var(value, key_param.to_s, value_param)
        end
        
        def to_each(to_each_var, key_param, value_param)
            tmp = to_each_var
            tmp.each do |key, value|
              to_store_value = (value.class == Hash) ? 
                          to_each(value, key_param, value_param) : 
                          to_process(value, key_param, value_param)
            
              to_each_var.store(key, to_store_value)
            end
            to_each_var = tmp
            return to_each_var
        end

        def build(to_filter)
            data = @cfg.config[:builder]
            params = @cfg.config[:params]
            internal_params = params
            prefix  = internal_params[:PREFIX] #
          
            data = filter_tool(data, to_filter)
            data.each do |tool, command|
                prefix_path_to_store = "#{prefix}/#{tool}" #
                internal_params.store(:PREFIX, prefix_path_to_store) if !prefix.nil? #
                
                @git_manager.set_git(command[:git]) 
                internal_params.store(:@SOURCE, "#{$SOURCE}/tools/#{@git_manager.name}") 
                @dir_manager.delete_build_dir(tool)

                internal_params.each do |key_param, value_param|
                  to_each(command, key_param, value_param)
                end
                exit if !@var_manager.check_if_set(command)
            
                @dir_manager.create_directories(tool)
                @git_manager.get_clone()
                @dir_manager.check_module_file(command[:module_file]) if command.has_key? :module_file
                
                path_make_log = "#{$SOURCE}/#{$FRAMEWORK}/logs/#{tool}/make.log"
                out = File.open(path_make_log, 'w')
                puts "Installing #{tool}.."
                status = system "cd #{$SOURCE}/tools/build/#{tool} ; " + 
                                 command[:execute], out: out, err: out
                out.close()
                
                if status and command.has_key? :module_file
                  @dir_manager.create_module_file(internal_params[:PREFIX], tool, command[:module_file])
                end
                @status_manager.set_status(status, tool)
            end
          end
    end
end
