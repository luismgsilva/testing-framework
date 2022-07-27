module Status_Manager

  class Status_Manager
  # attr_reader :status
    attr_reader :path_to_status
    def initialize
     @path_to_status = "#{$SOURCE}/.bla/logs/status"
    end
    

    def set_status(status, tool)

      status_msg = status ? "Passed" : "Failed"
      puts status_msg
      
      system "echo #{status_msg}: #{tool} >> #{@path_to_status} ;
              sed -i 's/^.*: #{tool}/#{status_msg}: #{tool}/' #{@path_to_status} > /dev/null 2>&1 ;
              sort -u #{@path_to_status} -o #{@path_to_status}"
    end
  end
end
