require 'spec_helper'

describe 'json request' do
  include Rack::Test::Methods
  it 'should receive allowed' do
    2.times { get '/json', {}, {'HTTP_ACCEPT' => 'application/json'} }

    expect(last_response.content_type).to eq 'application/json'
    expect(last_response.body).to eq 'Rate Limit Exceeded'
  end
end
