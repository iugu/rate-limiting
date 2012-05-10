require 'spec_helper'

def app
  @test_app ||= test_app
  @app ||= RateLimiting.new(@test_app) do |r|
    r.define_rule(:match => '/test', :metric => :rph, :type => :fixed, :limit => 2)
  end
end

describe "Frequency/rph rule request" do
  include Rack::Test::Methods

  it 'should be allowed if not exceed limit' do
    get '/test', {}, {'HTTP_ACCEPT' => "text/html"}
    last_response.body.should show_allowed_response
  end

  it 'should not be allowed if exceed limit' do
    3.times { get '/test', {}, {'HTTP_ACCEPT' => "text/html"} }
    last_response.body.should show_not_allowed_response
  end
  
end
