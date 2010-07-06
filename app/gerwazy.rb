require 'sinatra/base'
require 'erb'
require 'mongo'
require 'yaml'
require 'ostruct'
require 'cgi'

class Application
  @@config = OpenStruct.new YAML.load_file(File.dirname(__FILE__) + '/config/app.yml')
  @@db     = Mongo::Connection.new(@@config.db['host'], @@config.db['port']).db(@@config.db['db_name'])

  def self.config
    @@config
  end

  def self.db
    @@db
  end
end

class Timing < Application
  @@coll   = self.db.collection(@@config.db['collection_name'])
  
  def self.paginate(params)
    per_page = 20
    query = {}
    options = {
      :sort => [params[:sort]],
      :limit => per_page,
      :skip => (params[:page] - 1)*per_page
    }

    if params[:path]
      query['path'] = Regexp.new(params[:path])
    end

    if params[:path]
      query['path'] = Regexp.new(params[:path])
    end

    if params[:time]
      query['time'] = {}
      if params[:time][0].nil?
        query['time'].merge!('$gte' => 0)
      else
        query['time'].merge!('$gte' => params[:time][0])
      end
      if params[:time][1]
        query['time'].merge!('$lte' => params[:time][1])
      end
    end

    if params[:created_at]
      query['created_at'] = {}
      if params[:created_at][0].nil?
        query['created_at'].merge!('$gte' => DateTime.new(y=1995,m=1,d=1, h=0,min=0,s=0).to_time)
      else
        query['created_at'].merge!('$gte' => params[:created_at][0].to_time)
      end
      if params[:created_at][1].nil?
        query['created_at'].merge!('$lte' => DateTime.new(y=Time.now.year+1,m=1,d=1, h=0,min=0,s=0).to_time)
      else
        query['created_at'].merge!('$lte' => params[:created_at][1].to_time)
      end
    end

    if params[:status]
      query['status'] = params[:status]
    end

    total_entries = self.collection.find(query, {}).count
    
    results = self.collection.find(query, options)

    if params[:page]*per_page < total_entries
      def results.has_next_page?; true; end
    else  
      def results.has_next_page?; false; end
    end

    if params[:page] > 1
      def results.has_prev_page?; true; end
    else
      def results.has_prev_page?; false; end
    end

    results
  end

  def self.collection 
    @@coll
  end
end

class Helper
  def self.link_to(inner_text, uri, params = {}, html_options={})
    i = 0
    params.each_pair do |name, value|
      name = CGI.escape(name.to_s)
      value = CGI.escape(value.to_s)
      if i == 0
        uri << "?"
      else
        uri << "&"
      end
      uri << "#{name}=#{value}"
      i += 1
    end
    "<a href=\"#{uri}\">#{inner_text}</a>"
  end
end

class Gerwazy < Sinatra::Base
  set :static, true
  set :public, File.dirname(__FILE__) + '/static'

  get '/' do
    @page = (params['page'] || 1).to_i
    @sort_param = params['sort_param'] || 'created_at'
    @sort_dir = (params['sort_dir'] || 'desc').to_sym

    @time_from = 200
    @time_to = 900

    @created_at_from = DateTime.new(y=2008,m=3,d=22, h=16,min=30,s=12)

    
    @timings = Timing.paginate :page => @page, :sort => [@sort_param, @sort_dir],
      :path => "dashboard", :status => 200, :time => [@time_from, @time_to], 
      :created_at => [@created_at_from, @created_at_to]
      
    erb :index
  end
end
