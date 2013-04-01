require 'rubygems'
require 'sinatra'
require 'translate.rb'
require 'sinatra/sugar'

set :bind, '0.0.0.0'

get '/' do
  erb :index, :locals => {:error => nil}
end

get '/:hash' do
  if (params[:hash] != "favicon.ico")
    newurl=geturl(params[:hash])
    redirect to(newurl)
  end
end

post '/' do
  if settings.development?
     port = ":" + settings.port.to_s
  else
    port = ""
  end

  begin
    oldurl = params[:oldurl]
    newurl=makeurl(oldurl)
    erb :index, :locals => {:domain => request.host + port, :newurl => newurl, :error => nil}
  rescue ArgumentError => e
    erb :index, :locals => {:error => e.to_s }
  rescue SQLite3::Exception => e
    erb :index, :locals => {:error => "Database error: " + e.to_s }
  end
end
