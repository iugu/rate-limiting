require "spec_helper"

describe "response headers" do
  include Rack::Test::Methods

  context "limited request" do
    before(:each) do
      get '/header', {}, {'HTTP_ACCEPT' => 'text/html'}
    end

    it 'should have x-RateLimit-Limit' do
      last_response.header.should include "x-RateLimit-Limit"
    end
  
    it 'should have x-RateLimit-Remaining' do
      last_response.header.should include "x-RateLimit-Remaining"
    end
  
    it 'should have x-RateLimit-Reset' do
      last_response.header.should include "x-RateLimit-Reset"
    end
    
    it 'should have the right limit' do
      last_response.header['x-RateLimit-Limit'].should == "1"
    end

    it 'should have the right remaining' do
      last_response.header['x-RateLimit-Remaining'].should == "0"
    end

  end

  context "not limited request" do

    before(:each) do
      get '/not_limited'
    end

    it 'should have x-RateLimit-Limit' do
      last_response.header.should_not include "x-RateLimit-Limit"
    end
    
    it 'should have x-RateLimit-Remaining' do
      last_response.header.should_not include "x-RateLimit-Remaining"
    end
  
    it 'should have x-RateLimit-Reset' do
      last_response.header.should_not include "x-RateLimit-Reset"
    end

  end


end
