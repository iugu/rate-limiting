require 'spec_helper'

describe "xml request" do

  include Rack::Test::Methods

  it 'should receive allowed' do
    2.times { get '/xml', {}, {'HTTP_ACCEPT' => "text/xml"} } 
    last_response.content_type.should == "text/xml"
  end 

end

