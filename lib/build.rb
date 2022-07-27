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

        def build(to_filter)
            data = @cfg.config[:builder]
            params = @cfg.config[:params]
            prefix = params[:PREFIX] 
             
            data = filter_tool(data, to_filter)
            data.each do |tool, command|
                prefix_path_to_store = "#{prefix}/#{tool}" #
                params.store(:PREFIX, prefix_path_to_store) if !prefix.nil?
                
                @git_manager.set_git(command[:git]) 
                params.store(:@SOURCE, "#{$SOURCE}/tools/#{@git_manager.name}")
                params.store(:@BUILDNAME, tool.to_s)
                @dir_manager.delete_build_dir(tool)
                 
                command = @var_manager.prepare_data(command, params)
                
                @dir_manager.create_directories(tool)
                @git_manager.get_clone()
           #     @dir_manager.check_module_file(command[:module_file]) if command.has_key? :module_file
                
                module_path = "#{params[:MOD_PREFIX]}/#{tool}" 
                @dir_manager.create_dir(module_path)
                
                path_make_log = "#{$SOURCE}/#{$FRAMEWORK}/logs/#{tool}/make.log"
        
                out = File.open(path_make_log, "w")
                puts "Installing #{tool}.."
                if command[:execute].class == String
                  status = system "cd #{$SOURCE}/tools/build/#{tool} ; " + 
                                 command[:execute], out: out, err: out
                elsif command [:execute].class == Array
                  command[:execute].each do |m|
                    status = system "cd #{$SOURCE}/tools/build/#{tool} ;  
                                    echo #{m} ;" +
                                     m, out: out, err: out
                  end
                end
                out.close()
                #if status and command.has_key? :module_file
                #  @dir_manager.create_module_file(internal_params[:PREFIX], tool, command[:module_file])
                #end
                @status_manager.set_status(status, tool)
            end
          end
    end
end
