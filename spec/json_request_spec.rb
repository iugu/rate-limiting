require 'spec_helper'

def app 
  @test_app ||= test_app
  @app ||= RateLimiting.new(@test_app) do |r| 
    r.define_rule(:match => '/test', :metric => :rph, :type => :frequency, :limit => 60) 
  end 
end

describe "json request" do
  include Rack::Test::Methods
  it 'should receive allowed' do
    2.times { get '/test', {}, {'HTTP_ACCEPT' => "application/json"} } 
    last_response.content_type.should == "application/json"
  end 
end

