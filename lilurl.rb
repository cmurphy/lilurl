require 'rubygems'
require 'sinatra'
require 'translate.rb'

set :bind, '0.0.0.0'

$domain = 'localhost:4567'

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
  begin
    oldurl = params[:oldurl]
    newurl=makeurl(oldurl)
    erb :index, :locals => {:domain => $domain, :newurl => newurl, :error => nil}
  rescue ArgumentError => e
    erb :index, :locals => {:error => e.to_s }
  end
end
