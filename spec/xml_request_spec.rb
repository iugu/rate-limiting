require 'spec_helper'

def app 
  @test_app ||= test_app
  @app ||= RateLimiting.new(@test_app) do |r| 
    r.define_rule(:match => '/test', :metric => :rph, :type => :frequency, :limit => 60) 
  end 
end

describe "xml request" do

  include Rack::Test::Methods

  it 'should receive allowed' do
    2.times { get '/test', {}, {'HTTP_ACCEPT' => "text/xml"} } 
    last_response.content_type.should == "text/xml"
  end 

end

