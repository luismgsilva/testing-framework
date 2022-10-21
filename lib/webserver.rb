require 'sinatra/base'



class WebServer < Sinatra::Base 

  set :default_content_type, 'application/json'

  def self.execute(opts)
    get "/" do
    end
   
    # get "/compare/:task/:hash1/:hash2" do
    #   Manager.instance.compare(params[:hash1], params[:hash2], nil, params[:task])
    # end
    get "/compare/:hash1/:hash2" do
      # Manager.instance.compare(params[:hash1], params[:hash2], nil, params[:task])
      args = ["#{params[:hash1]}:#{params[:hash2]}"]
      Manager.instance.compare_agregator(args)
    end
    get "/compare/:hash1/:hash2/:opts" do
      # Manager.instance.compare(params[:hash1], params[:hash2], nil, params[:task])
      args = ["#{params[:hash1]}:#{params[:hash2]}", params[:opts]]
      Manager.instance.compare_agregator(args)
    end


    get "/ls/:task/:hash" do
      Manager.instance.ls(params["task"], params["hash"])
    end
    get "/cat/:task/:hash/:file" do
      Manager.instance.cat(params[:task], params[:hash], params[:file])
    end
    get "/status/:hash" do
      Manager.instance.status(params[:hash])
    end
    get "/log/:task/:hash" do
      Manager.instance.log(params[:task], params[:hash])
    end
    get "/diff/:hash1/:hash2" do
      Manager.instance.diff(params[:hash1], params[:hash2])
    end
    get "/search/:args" do
      GitManager.search_log(params[:args])
    end
    run!
  end
end

