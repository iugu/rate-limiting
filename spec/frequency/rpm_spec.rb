require 'spec_helper'

def app 
  @test_app ||= test_app
  @app ||= RateLimiting.new(@test_app) do |r| 
    r.define_rule(:match => '/test', :metric => :rpm, :type => :frequency, :limit => 1) 
  end 
end

describe "Frequency/rpm rule request" do
  include Rack::Test::Methods

  it 'should be allowed if not exceed 1 request per min' do
    get '/test'
    last_response.body.should show_allowed_response
  end 

  it 'should not be allowed if exceed 1 request per min' do
    2.times { get '/test'}
    last_response.body.should show_not_allowed_response
  end 
  
end

