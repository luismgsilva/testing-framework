module Var_Manager

  class Var_Manager
      def verify_if_var_exists(builder, command)
          arr = get_var_from_json(builder)
          return arr.include? command.upcase
      end

      def var_list(cfg)
          var_list = get_var_from_json(cfg.config[:builder])
          params = cfg.config[:params].keys

          params.map! { |p| p.to_s.upcase }            
          var_list.select! { |p| p !~ /\@/ }

          var_list.each do |e|
            if ! params.include? (e)
              puts "Internal Variable #{e} not defined"
            else
              value = e.downcase.to_sym
              hash = cfg.config[:params]
              puts "Internal Variable #{e} defined: #{hash[value]}"
            end
          end
      end

      def check_var_global(builder)
          vars = get_var_from_json(builder)

          vars.select! { |a| a =~ /\@/ }
          vars = get_global_var_matching(vars)

          if !vars.empty?
            puts "ERROR: Intern Variable/S #{vars} not defined." ; exit
          end
        end

      def get_global_var_matching(vars)
          arr = []
          vars.each do |var|
              tmp = var.gsub("@", "$").to_sym
              arr.append(var) if !global_variables.include? (tmp)
          end
          return arr
      end

      def get_var_variables(str)
          exprex = /\$var\(([^)]+)\)/
          if str =~ exprex
            return str.scan(exprex).flatten
          end
      end

      def get_var_from_json_recursive(to_each, arr)
        to_each.each do |key, value|
          var_variables = (value.class == Hash) ? get_var_from_json_recursive(value, arr) : get_var_variables(value)
          arr.append(var_variables) if var_variables != nil
        end
        return arr.flatten.uniq
      end

      def get_var_from_json(builder)
          arr = get_var_from_json_recursive(builder, [])
          return arr.flatten.uniq
      end

      def check_if_set(command)
        is_set = true
        command.each do |key, value|  
          vars = get_var_variables(value)
          if !vars.nil?
            vars.select! { |var| var !~ /\@/ }
            vars.each do |var|
              puts "ERROR: variable #{var} not set"
            end
            is_set = false
          end
        end
        return is_set
      end

      def process_var(str, name, subs)
        return str.gsub(/\$var\((#{name})\)/) do |m|
          subs
        end
      end   
  end
end
