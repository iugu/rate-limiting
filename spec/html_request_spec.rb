require 'spec_helper'

describe "html request" do

  include Rack::Test::Methods

  it 'should receive allowed' do
    expect(app).to receive(:allowed?).twice
    get '/test', {}, {'HTTP_ACCEPT' => "text/html"}
    get '/test2', {}, {'HTTP_ACCEPT' => "text/html"}
  end

  it 'should receive allowed' do
    2.times { get '/html', {}, {'HTTP_ACCEPT' => "text/html"} }
    expect(last_response.content_type).to eq "text/html"
  end

end
