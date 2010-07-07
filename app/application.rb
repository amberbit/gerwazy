require 'yaml'
require 'ostruct'
require 'mongo'
require 'cgi'
require 'date'


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

class Helper

  def self.create_params_arr params, prefix=nil
    res = []
    params.each_pair do |name, value|
      if prefix
        name = "#{prefix}[#{name}]"
      end
      name = CGI.escape(name.to_s)
      value = CGI.escape(value.to_s)
      res << "#{name}=#{value}"     
    end
    res
  end

  def self.link_to(inner_text, uri, params = {}, html_options={})
    i = 0
    res = []
    params.select {|k,v| v.class == Hash}.each {|k,v| res += self.create_params_arr v, k }
    res += self.create_params_arr(params.select {|k,v| v.class != Hash})
    uri += "?" + res.join("&")
    "<a href=\"#{uri}\">#{inner_text}</a>"
  end

  def self.date_select(name, date = nil)
    res = "Day: <select name=\"#{name}[d]\">"
    31.times do |day|
      day += 1
      res << "<option #{date and date.day==day ? 'selected="selected"' : ''} value=\"#{day}\">#{day}</option>"
    end
    res << "</select>"
    
    res << "Month: <select name=\"#{name}[m]\">"
    months = Date::MONTHNAMES
    index = 0
    for i in (months)
      if index > 0
        res << "<option #{date and date.month==index ? 'selected="selected"' : ''} value=\"#{index}\">#{i}</option>"
      end
      index+=1
    end
    res << "</select>"

    res << "Year: <select name=\"#{name}[y]\">"
    20.times do |year|
      year += 1995
      res << "<option #{date and date.year==year ? 'selected="selected"' : ''} value=\"#{year}\">#{year}</option>"
    end
    res << "</select>"

    res << "Hour: <select name=\"#{name}[h]\">"
    24.times do |hour|
      res << "<option #{date and date.hour==hour ? 'selected="selected"' : ''} value=\"#{hour}\">#{hour}</option>"
    end
    res << "</select>"

    res << "Minute: <select name=\"#{name}[min]\">"
    60.times do |min|
      res << "<option #{date and date.min==min ? 'selected="selected"' : ''} value=\"#{min}\">#{min}</option>"
    end
    res << "</select>"
  end

  def self.create_date hash
    unless hash.blank?
      @created_at_from = DateTime.new(
        hash['y'].to_i, hash['m'].to_i, hash['d'].to_i,
        hash['h'].to_i, hash['min'].to_i, 0
      )
    else
      @created_at_from = DateTime.now
    end
  end
end

class Object
  def blank?
    self == nil or (self.respond_to?(:empty?) and self.empty?)
  end
end
