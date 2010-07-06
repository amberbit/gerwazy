require File.join(File.dirname(File.expand_path("__FILE__")), "lib/gerwazy")
require 'spec'
require 'rack/test'
require 'testapp'
require 'mongo'

DB_NAME = "gerwazy_test_db"
COLL_NAME = "test"

describe Gerwazy do
  include Rack::Test::Methods

  def app
    Gerwazy.new(TestApp.new, DB_NAME, COLL_NAME)
  end

  def coll
    @mongo.db(DB_NAME).collection(COLL_NAME)
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

  it "should not alter response content returned by app" do
    get "/"
    last_response.body.should == 'Hello World'
  end

  it "should not alter response status returned by app" do
    get "/"
    last_response.should be_ok
  end

  it "should save request path in the database" do
    get "/"
    coll.find("path" => '/').count.should eql(1)
  end

  it "should save request time in the database" do
    get "/"
    get "/response1"

    time1 = coll.find("path" => '/').first['time']
    time1.should > 400
    time1.should < 600

    time2 = coll.find("path" => '/response1').first['time']
    time2.should > 1400
    time2.should < 1600
  end

  it "should save request timestamp in the database" do
    get "/"
    timestamp = coll.find("path" => '/').first['created_at']
    timestamp.should be_instance_of(Time)
  end
 end
