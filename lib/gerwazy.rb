require 'rack'
require 'mongo'

class Gerwazy
  def initialize(app, db_name = "gerwazy", collection_name = "timings", host = "localhost", port = 27017)
    @app = app
    @db   = Mongo::Connection.new(host, port).db(db_name)
    @coll = @db.collection(collection_name)
  end

  def call(env)
    request = Rack::Request.new(env.clone)

    start_time = Time.now
    status, headers, response = @app.call(env)
    end_time = Time.now

    @coll.insert({'path' => request.path, 
                  'created_at' => Time.now, 
                  'status' => status, 
                  'time' => (1000.0 * (end_time-start_time)).to_i })

    [status, headers, response]
  end
end

