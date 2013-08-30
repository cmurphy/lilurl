require 'rubygems'
require 'sinatra'
require 'sinatra/contrib'
require 'json'
require './translate.rb'

set :bind, '0.0.0.0'

get '/' do
  erb :index, :locals => {:error => nil}
end

get '/:hash' do
  begin
    if params[:hash] != "favicon.ico"
      newurl=geturl(params[:hash])
      redirect to(newurl)
    end
  rescue ArgumentError => e
    erb :index, :locals => {:error => e.to_s}
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
    postfix = params[:postfix]
    newurl=makeurl(oldurl, postfix)
    newurl_hash = { 'newurl' => newurl }
    respond_with :index do |format|
      format.html { erb :index, :locals => {:domain => request.host + port, :newurl => newurl, :error => nil}}
      format.json { "{newurl: http://#{request.host}#{port}/#{newurl}}" }
    end
  rescue ArgumentError => e
    respond_with :index do |format|
      format.html { erb :index, :locals => {:error => e.to_s }}
      format.json { "{error: #{e.to_s}}" }
    end
  rescue SQLite3::Exception => e
    erb :index, :locals => {:error => "Database error: " + e.to_s }
  end
end
