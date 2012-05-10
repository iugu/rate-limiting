require 'spec_helper'

def app 
  @test_app ||= test_app
  @app ||= RateLimiting.new(@test_app) do |r| 
    r.define_rule(:match => '/test', :metric => :rpd, :type => :frequency, :limit => 3600)  
  end 
end

describe "Frequency/rpd rule request" do
  include Rack::Test::Methods

  it 'should be allowed if not exceed 1 request per min' do
    get '/test', {}, {'HTTP_ACCEPT' => "text/html"}
    last_response.body.should show_allowed_response
  end 

  it 'should not be allowed if exceed 1 request per min' do
    2.times { get '/test', {}, {'HTTP_ACCEPT' => "text/html"} }
    last_response.body.should show_not_allowed_response
  end 
  
end

