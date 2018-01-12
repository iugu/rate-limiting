require 'spec_helper'

describe "Fixed/rpd rule request" do
  include Rack::Test::Methods

  it 'should be allowed if not exceed limit' do
    get '/fixed/rpd', {}, {'HTTP_ACCEPT' => "text/html"}
    expect(last_response.body).to show_allowed_response
  end

  it 'should not be allowed if exceed limit' do
    2.times { get '/fixed/rpd', {}, {'HTTP_ACCEPT' => "text/html"} }
    expect(last_response.body).to show_not_allowed_response
  end

end
