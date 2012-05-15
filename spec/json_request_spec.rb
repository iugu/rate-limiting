require 'spec_helper'

describe "json request" do
  include Rack::Test::Methods
  it 'should receive allowed' do
    2.times { get '/json', {}, {'HTTP_ACCEPT' => "application/json"} } 
    last_response.content_type.should == "application/json"
  end 
end

