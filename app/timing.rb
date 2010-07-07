require 'application'

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

    if !params[:path].blank?
      query['path'] = Regexp.new(params[:path])
    end

    if params[:time]
      query['time'] = {}
      if params[:time][0].blank?
        query['time'].merge!('$gte' => 0)
      else
        query['time'].merge!('$gte' => params[:time][0].to_i)
      end
      unless params[:time][1].blank?
        query['time'].merge!('$lte' => params[:time][1].to_i)
      end
    end

    if params[:created_at]
      query['created_at'] = {}
      query['created_at'].merge!('$gte' => params[:created_at][0].to_time)
      query['created_at'].merge!('$lte' => params[:created_at][1].to_time)
    end

    if !params[:status].blank?
      query['status'] = params[:status].to_i
    end

    total_entries = self.collection.find(query, {}).count
    
    results = self.collection.find(query, options)

    singleton = class << results; self; end
    
    singleton.instance_eval "define_method(:has_next_page?) { #{params[:page]*per_page < total_entries} }"
    singleton.instance_eval "define_method(:has_prev_page?) { #{params[:page] > 1} }"
    min_time = self.collection.find_one(query, { :sort => [['time', :asc]]})['time']
    max_time = self.collection.find_one(query, { :sort => [['time', :desc]]})['time']
    singleton.instance_eval "define_method(:min_time) { #{min_time} }"
    singleton.instance_eval "define_method(:max_time) { #{max_time} }"
    results
  end

  def self.collection 
    @@coll
  end
end
