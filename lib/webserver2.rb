require 'sinatra/base'

class WebServer2 < Sinatra::Base

  set :default_content_type, 'application/json'

  # def handler(message)
  #   data = JSON.parse(request.body.read, symbolize_names: true)
  #   puts data
  #   begin
  #     yield data
  #     { code: 20, message: message }.to_json
  #   rescue Exception => e
  #     { code: 22, message: e }.to_json
  #   end
  # end

  # def get_handler()
  #   begin
  #     yield.to_json
  #   rescue Exception => e
  #     { code: 22, message: e }.to_json
  #   end
  # end

  def self.execute(opts)

    while(opts.any?)
      case opts.shift
      when '-p', '--port'
        set :port, opts.shift
      when '-h', '--help'
        puts "."
      else
        puts "Invalid argument, using default port 4567"
      end
    end if opts


    github_block = Proc.new do
      data = JSON.parse(request.body.read, symbolize_names: true)
      cmd = "echo '#{JSON.pretty_generate(data)}' > /tmp/github"
      Helper.system(cmd)
    end
    post "/github", &github_block


  # GET
    # `bsf sources list`
    get "/sources/list" do
    end
    # `bsf sources show`
    get "/sources/show" do
    end

    # `bsf vars`
    get "/vars" do
      begin
        # Why? Im tired.
        data = { text: VarManager.instance.var_list().split("\n") }
        content_type :json
        data.to_json
      rescue Exception => e
        { code: 22, message: e }.to_json
      end
    end

    # `bsf tasks`
    get "/tasks" do
      begin
        data = {}
        Config.instance.tasks.keys.each do |task|
          data[task] = {description: Config.instance.task_description(task)}
        end
        content_type :json
        data.to_json
      rescue Exception => e
        { code: 22, message: e }.to_json
      end
    end
    # ----------------------------------------------

    # `bsf search $<opts>``
    get "/search/:opts" do
    end
    # ----------------------------------------------

    # `bsf log $<task>`
    get "/log/:task/?:hash?" do
      begin
        contents = Log.log(opts[:task], opts[:hash], nil)
        { log: contents }
      rescue Exception => e
        { code: 22, message: e }.to_json
      end
    end
    # ----------------------------------------------

    # `bsf status`
    get "/status/?:hash?" do
      begin
        contents = Status.get_task_status(params[:hash])
        data = {}
        contents.each_line do |line|
          status, task = line.chomp.split(": ")
          data[task] = status
        end
        content_type :json
        data.to_json
      rescue Exception => e
        { code: 22, message: e }.to_json
      end
    end
    # ----------------------------------------------

    # `bsf ls <task> {commit_id}` WORKS
    get "/ls/:task/?:hash?" do
      begin
        # data = { files: Ls.ls(params[:task], params[:hash]).split("\n") }
        data = Ls.ls(params[:task], params[:hash]).split("\n")
        content_type :json
        data.to_json
      rescue Exception => e
        { code: 22, message: e }.to_json
      end
    end

    # ----------------------------------------------


    # `bsf cat <task> <file> {commit_id}`
    get "/cat/:task/?:hash?" do
      begin
        data = { file: Cat.cat(params[:task], params[:hash], params[:file]) }
        content_type :json
        data.to_json
      rescue Exception => e
        { code: 22, message: e }.to_json
      end
    end
    # ----------------------------------------------


    # `bsf compare <task> $<opts>`
    get "/compare/:task/:opts" do
      begin
        args = ["#{params[:hash1]}:#{params[:hash2]}", "-o json"]
        data = Compare.compare(params[:task], args)
        content_type :json
        data.to_json
      rescue Exception => e
        { code: 22, message: e }.to_json
      end
    end
    # ----------------------------------------------


    # `bsf report <task> $<opts>`
    get "/report/:task/:opts" do
    end


    post "/sources" do
      begin
        data = JSON.parse(request.body.read, symbolize_names: true)
        Source.get_sources(params[:source], params[:"single-branch"])
        content_type :json
        { code: 20, message: "Repository cloned successfully" }
      rescue Exception => e
        { code: 22, message: e }.to_json
      end
    end

    delete "/sources" do
      begin
        data = JSON.parse(request.body.read, symbolize_names: true)
        Source.delete_sources(params[:source])
        content_type :json
        { code: 20, message: "Repository deleted successfully" }
      rescue Exception => e
        { code: 22, message: e }.to_json
      end
    end

    # `bsf set <var>=<value>`
    put "/vars" do
      begin
        data = JSON.parse(request.body.read, symbolize_names: true)
        VarManager.instance.set(data[:var], data[:value])
        VarManager.instance.save
        content_type :json
        { code: 20, message: "Input variable updated successfully" }
      rescue Exception => e
        { code: 22, message: e }.to_json
      end
    end


    put "/git" do
      begin
        data = JSON.parse(request.body.read, symbolize_names: true)
        GitManager.internal_git(params[:gitcommand])
        content_type :json
        { code: 20, message: "Git command executed successfully" }
      rescue Exception => e
        { code: 22, message: e }.to_json
      end
    end

    # `bsf saveconfi <path>`
    post "/saveconfig" do
      begin
        data = JSON.parse(request.body.read, symbolize_names: true)
        Config.save_config(params[:pathtosave])
        content_type :json
        { code: 20, message: "Config saved successfully" }
      rescue Exception => e
        { code: 22, message: e }.to_json
      end
    end


    # `bsf execute ${task}`
    post "/execute" do
      begin
        data = JSON.parse(request.body.read, symbolize_names: true)
        Build.build(params[:task], params[:confirm], params[:parallel])
        content_type :json
        { code: 20, message: "Execution finished" }
      rescue Exception => e
        { code: 22, message: e }.to_json
      end
    end



    # `bsf publish`
    post "/publish" do
      begin
        data = JSON.parse(request.body.read, symbolize_names: true)
        Publish.publish()
        content_type :json
        { code: 20, message: "Publish successful" }
      rescue Exception => e
        { code: 22, message: e }.to_json
      end
    end

    # `bsf clean ${task}`
    post "/clean" do
      begin
        data = JSON.parse(request.body.read, symbolize_names: true)
        Clean.clean(params[:task], params[:confirm])
        content_type :json
        { code: 20, message: "Publish successful" }
      rescue Exception => e
        { code: 22, message: e }.to_json
      end
    end

    run!
  end
end

