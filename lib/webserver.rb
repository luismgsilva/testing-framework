require 'sinatra/base'

class WebServer < Sinatra::Base 

  set :default_content_type, 'application/json'

  def handler(message)
    data = JSON.parse(request.body.read, symbolize_names: true)
    puts data
    begin
      yield data
      { code: 20, message: message }.to_json
    rescue Exception => e
      { code: 22, message: e }.to_json
    end
  end

  def get_handler()
    begin
      yield.to_json
    rescue Exception => e
      { code: 22, message: e }.to_json
    end
  end

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

    post "/github" do
      data = JSON.parse(request.body.read, symbolize_names: true)
      cmd = "echo '#{JSON.pretty_generate(data)}' > /tmp/github"
      Helper.system(cmd)
    end

  # GET
    # `bsf sources list`
    get "/sources/list" do
    end
    # `bsf sources show`
    get "/sources/show" do
    end
    # `bsf vars`
    get "/vars" do
      vars = VarManager.instance.var_list()
    end
    # `bsf tasks`
    get "/tasks" do
      get_handler do
        data = {}
        Config.instance.tasks.keys.each do |task|
          data[task] = {description: Config.instance.task_description(task)}
        end
        data
      end
    end
    # `bsf search $<opts>``
    get "/search/:opts" do
    end
    # `bsf log $<task>`
    get "/log/:task/:hash" do
      get_handler do
        contents = Manager.instance.log(params[:task], params[:hash], nil)
        { log: contents }
      end
    end
    # `bsf status`
    get "/status/:hash" do
      get_handler do
        contents = Manager.instance.status(params[:hash])
        data = []
        contents.each_line do |line|
          status, name = line.chomp.split(': ')
          data << { name: name, status: status }
        end
        json
      end
    end
    # `bsf ls <task> {commit_id}` WORKS
    get "/ls/:task" do
      data = {}
      data[:files] = Manager.instance.ls(params[:task], nil).split("\n")

      content_type :json
      data.to_json
    end
    # `bsf cat <task> <file> {commit_id}`
    get "/cat/:task/:file" do
    end
    # `bsf compare <task> $<opts>`
    get "/compare/:task/:hash1/:hash2" do
      args = ["#{params[:hash1]}:#{params[:hash2]}", "-o json"]
      content_type :json
      JSON.parse(Manager.instance.compare(params[:task], args)).to_json
    end
    # `bsf report <task> $<opts>`
    get "/report/:task/:opts" do
    end

  # POST
    # `bsf sources get ${sources}`
    post "/sources" do
      handler("Repository cloned successfully") do |opts|
        Source.get_sources(opts[:source], opts[:single])
      end
    end
    # `bsf sources delete <sources>`
    delete "/sources" do
      handler("Repository deleted successfully") do |opts|
        Source.delete_sources(opts[:source])
      end
    end

    # `bsf set <var>=<value>`
    put "/vars" do
      handler("Input variable updated successfully") do |opts|
        VarManager.instance.set(opts[:var], opts[:value])
        VarManager.instance.save
      end
    end

    put "/git" do
      handler("Git command executed successfully") do |opts|
        GitManager.internal_git(opts[:gitcommand])
      end
    end

    # `bsf saveconfi <path>`
    post "/saveconfig" do
      handler("Config saved successfully") do |opts|
        Config.save_config(opts[:path])
      end
    end

    # `bsf execute ${task}`
    post "/execute" do
      handler("Execution finished") do |opts|
        # Manager.instance.build(opts[:task], opts[:y])
        Manager.instance.build(opts[:task], opts[:y])
      end
    end
    # `bsf publish`
    post "/publish" do
      handler("Publish successful") do |opts|
        Manager.instance.publish()
      end
    end
    # `bsf clean ${task}`
    post "/clean" do
      handler("Clean successful") do |opts|
        Manager.instance.clean(opts[:task], opts[:confirm])
      end
    end
    run!
  end
end

