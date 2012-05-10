require 'spec_helper'

def app 
  @test_app ||= test_app
  @app ||= RateLimiting.new(@test_app) do |r| 
    r.define_rule(:match => '/test') 
  end 
end

describe "Any request" do

  include Rack::Test::Methods

  it 'should receive allowed' do
    app.should_receive(:allowed?).twice
    get '/test', {}, {'HTTP_ACCEPT' => "text/html"}
    get '/test2', {}, {'HTTP_ACCEPT' => "text/html"}
  end 

end

