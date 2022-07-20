module Status_Manager

  class Status_Manager
   attr_reader :status
  
    def initialize
     @path_to_status = "#{$SOURCE}/.bla/logs/status.json"
      @status = (!File.file? @path_to_status) ?
        {} : JSON.parse(File.read(@path_to_status), symbolize_names: true)
    end

    def set_status(status, tool)

      # Dir.chdir($SOURCE)
      #status_msg = status ? "Passed" : "Failed. check logs: ./bla log #{tool}"
      status_msg = status ? "Passed" : "Failed"
      puts status_msg
    
      @status.store(status_msg.to_sym, tool)
      File.open(@path_to_status, 'w') do |f|
        f.write JSON.pretty_generate(@status)
      end
    end
  end
end
