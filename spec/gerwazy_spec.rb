require 'lib/rack/gerwazy'  # <-- your sinatra app
require 'spec'
require 'rack/test'
require 'testapp'
require 'mongo'

DB_NAME = "gerwazy_test_db"
COLL_NAME = "test"

describe "Rack::Gerwazy" do
  include Rack::Test::Methods

  def app
    Rack::Gerwazy.new(TestApp.new, DB_NAME, COLL_NAME)
  end

  before(:all) do
    @mongo = Mongo::Connection.new()
  end

  before(:each) do
    @mongo.drop_database(DB_NAME)
  end

  after(:all) do
    @mongo.drop_database(DB_NAME)
  end

  it "pass response returned by application when no recognized tags were found" do
    get '/'
    last_response.should be_ok
    last_response.body.should == 'Hello World'

    get '/response1'
    last_response.should be_ok
    last_response.body.should == "GET_response1"

    coll = @mongo.db(DB_NAME).collection(COLL_NAME)

    time1 = coll.find("path" => '/').first['time']
    time1.should > 400
    time1.should < 600

    time2 = coll.find("path" => '/response1').first['time']
    time2.should > 1400
    time2.should < 1600
  end
end
