require 'spec_helper'

describe "xml request" do

  include Rack::Test::Methods

  it 'should receive allowed' do
    2.times { get '/xml', {}, {'HTTP_ACCEPT' => "text/xml"} }
    expect(last_response.content_type).to eq "text/xml"
  end

end
