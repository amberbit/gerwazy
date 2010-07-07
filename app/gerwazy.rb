require 'sinatra/base'
require 'erb'
require 'application'
require 'timing'
require "sinatra/reloader"

class Gerwazy < Sinatra::Base
  set :static, true
  set :public, File.dirname(__FILE__) + '/static'
  register Sinatra::Reloader

  get '/' do
    @page = (params['page'] || 1).to_i
    @sort_param = params['sort_param'] || 'created_at'
    @sort_dir = (params['sort_dir'] || 'desc').to_sym

    @created_at_from = Helper.create_date params['created_at_from']
    @created_at_to = Helper.create_date params['created_at_to']
    @timings = Timing.paginate :page => @page, :sort => [@sort_param, @sort_dir],
      :path => params['path'], :status => params[:status], :time => [params['time_from'], params['time_to']], 
      :created_at => [@created_at_from, @created_at_to]
      
    erb :index
  end
end
