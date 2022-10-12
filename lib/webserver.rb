require 'sinatra/base'



class WebServer < Sinatra::Base 

  set :default_content_type, 'application/json'



  def self.execute(opts)
    get "/" do
      "Hello World!".to_json
    
    end
   
    get "/compare/:hash1/:hash2.:target" do
      Manager.instance.compare(params["hash1"], params["hash2"], "-t #{params[:target]}")
      
    end
    
    get "/ls/:task/:hash" do
      Manager.instance.ls(params["task"], params["hash"])
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

