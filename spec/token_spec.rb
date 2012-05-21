require "spec_helper"

describe "defined token rule" do
  include Rack::Test::Methods

  it 'should allow diferent ids' do
    get '/token', { :id => "1" }, {'HTTP_ACCEPT' => "text/html"}
    get '/token', { :id => "2" }, {'HTTP_ACCEPT' => "text/html"}
    last_response.body.should show_allowed_response
  end

  it 'should not allow equal ids' do
    2.times { get '/token', { :id => "1" }, {'HTTP_ACCEPT' => "text/html"} }
    last_response.body.should show_not_allowed_response
  end

  context "+ per_ip" do

    it 'should allow diferent ids' do
      get '/token/ip', { :id => "1" }, {'HTTP_ACCEPT' => "text/html"}
      get '/token/ip', { :id => "2" }, {'HTTP_ACCEPT' => "text/html"}
      last_response.body.should show_allowed_response
    end
  
    it 'should not allow equal ids' do
      2.times { get '/token/ip', { :id => "1" }, {'HTTP_ACCEPT' => "text/html"} }
      last_response.body.should show_not_allowed_response
    end
    
  
  end

end



