require 'spec_helper'

def app 
  @test_app ||= test_app
  @app ||= RateLimiting.new(@test_app) do |r| 
    r.define_rule(:match => '/test', :limit => 1) 
  end 
end

describe "html request" do

  include Rack::Test::Methods

  it 'should receive allowed' do
    app.should_receive(:allowed?).twice
    get '/test', {}, {'HTTP_ACCEPT' => "text/html"}
    get '/test2', {}, {'HTTP_ACCEPT' => "text/html"}
  end 

  it 'should receive allowed' do
    2.times { get '/test', {}, {'HTTP_ACCEPT' => "text/html"} } 
    last_response.content_type.should == "text/html"
  end 

end

