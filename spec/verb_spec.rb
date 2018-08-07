# frozen_string_literal: true
require "spec_helper"

describe "verb rule" do
  include Rack::Test::Methods

  context "verb is set" do
    it "should filter the designated verb" do
      get "/verb/get", {}, "HTTP_ACCEPT" => "text/html"
      get "/verb/get", {}, "HTTP_ACCEPT" => "text/html"
      expect(last_response.body).to show_not_allowed_response

      post "/verb/post", {}, "HTTP_ACCEPT" => "text/html"
      post "/verb/post", {}, "HTTP_ACCEPT" => "text/html"
      expect(last_response.body).to show_not_allowed_response
    end

    it "should allow requests with different verbs" do
      get "/verb/get", {}, "HTTP_ACCEPT" => "text/html"
      post "/verb/get", {}, "HTTP_ACCEPT" => "text/html"
      expect(last_response.body).to show_allowed_response

      get "/verb/post", {}, "HTTP_ACCEPT" => "text/html"
      post "/verb/post", {}, "HTTP_ACCEPT" => "text/html"
      expect(last_response.body).to show_allowed_response
    end

    it "should allow requests to a filtered path with a different verb" do
      post "/verb/get", {}, "HTTP_ACCEPT" => "text/html"
      post "/verb/get", {}, "HTTP_ACCEPT" => "text/html"
      expect(last_response.body).to show_allowed_response

      get "/verb/post", {}, "HTTP_ACCEPT" => "text/html"
      get "/verb/post", {}, "HTTP_ACCEPT" => "text/html"
      expect(last_response.body).to show_allowed_response
    end
  end
end
