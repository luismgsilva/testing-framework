module Var_Manager

  class Var_Manager
      def verify_if_var_exists(builder, command)
          arr = get_var_variables(builder)
          return arr.include? command
      end

      def var_list(cfg)
        var_list = get_var_variables(cfg.config) 
          params = cfg.config[:params].keys

          params.map! { |p| p.to_s.upcase }            
          var_list.select! { |p| p !~ /\@/ }

          var_list.each do |e|
            if ! params.include? (e)
              puts "Input Variable #{e} not defined"
            else
              value = e.to_sym
              hash = cfg.config[:params]
              puts "Input Variable #{e} defined: #{hash[value]}"
            end
          end
      end

      def check_var_global(builder)
          vars = get_var_variables(builder)

          vars.select! { |a| a =~ /\@/ }
          vars = get_global_var_matching(vars)

          abort("ERROR: Internal Variable/s #{vars} not defined.") if !vars.empty?
        end

      def get_global_var_matching(vars)
          arr = []
          vars.each do |var|
              tmp = var.gsub("@", "$").to_sym
              arr.append(var) if !global_variables.include? (tmp)
          end
          return arr
      end
      
      def get_var_variables(hash)
          str = JSON.pretty_generate(hash)
          exprex = /\$var\(([^)]+)\)/
          return str.scan(exprex).flatten.uniq
      end
      
      def prepare_data(hash, params)
        str = JSON.pretty_generate(hash)
        str = process_variables(str, params)
        return JSON.parse(str, symbolize_names: true)
      end

      def process_variables(str, params)
        return str.gsub(/\$var\(([A-Z0-9_@]+)\)/) do |m|
          abort("Input variable not set #{$1}.") if params[$1.to_sym].nil?
          params[$1.to_sym]
        end
      end
      
  end
end
