require 'lib/rack/gerwazy'  # <-- your sinatra app
require 'spec'
require 'rack/test'
require 'testapp'


describe "TestApp -- let's test our test infrastructure ;)" do
  include Rack::Test::Methods

  def app
    TestApp.new
  end

  it "says hello by default" do
    get '/'
    last_response.should be_ok
    last_response.body.should == 'Hello World'
  end
 
  it "renders response1 on /response1" do
    get "/response1"
    last_response.should be_ok
    last_response.body.should == "GET_response1"
  end

  it "renders response2 on /response2" do
    get "/response2"
    last_response.should be_ok
    last_response.body.should == "GET_response2"
  end

  it "should get page with two embeds on /embed_two" do
    get "/embed_two"
    last_response.should be_ok
    last_response.body.should == "[<get>/response1</get>] [<get>/response2</get>]"
  end
 
  it "should get page that will get another embed /embed_one" do
    get "/embed_one"
    last_response.should be_ok
    last_response.body.should == "<get>/embed_two</get>"
  end

  it "should get ajax or not ajax initial page" do
    get "/get_ajax_and_not_ajax"
    last_response.should be_ok
    last_response.body.should == "[<xhrget>/ajax_or_not</xhrget>] [<get>/ajax_or_not</get>]"
  end
end
