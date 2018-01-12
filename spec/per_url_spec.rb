require "spec_helper"

describe "per_url rule" do
  include Rack::Test::Methods

  context "true" do

    it 'should not allow equal urls' do
      get '/per_url/url1', {}, {'HTTP_ACCEPT' => "text/html"}
      get '/per_url/url1', {}, {'HTTP_ACCEPT' => "text/html"}
      expect(last_response.body).to show_not_allowed_response
    end

    it 'should allow different urls' do
      get '/per_url/url1', {}, {'HTTP_ACCEPT' => "text/html"}
      get '/per_url/url2', {}, {'HTTP_ACCEPT' => "text/html"}
      expect(last_response.body).to show_allowed_response
    end

  end

  context "false" do

    it 'should not allow different urls' do
      get '/per_match/url1', {}, {'HTTP_ACCEPT' => "text/html"}
      get '/per_match/url2', {}, {'HTTP_ACCEPT' => "text/html"}
      expect(last_response.body).to show_not_allowed_response
    end

  end



end
