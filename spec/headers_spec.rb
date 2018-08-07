# frozen_string_literal: true
require "spec_helper"

describe "response headers" do
  include Rack::Test::Methods

  context "limited request" do
    before(:each) do
      get "/header", {}, "HTTP_ACCEPT" => "text/html"
    end

    it "should have x-RateLimit-Limit" do
      expect(last_response.header).to include "x-RateLimit-Limit"
    end

    it "should have x-RateLimit-Remaining" do
      expect(last_response.header).to include "x-RateLimit-Remaining"
    end

    it "should have x-RateLimit-Reset" do
      expect(last_response.header).to include "x-RateLimit-Reset"
    end

    it "should have the right limit" do
      expect(last_response.header["x-RateLimit-Limit"]).to eq "1"
    end

    it "should have the right remaining" do
      expect(last_response.header["x-RateLimit-Remaining"]).to eq "0"
    end
  end

  context "not limited request" do
    before(:each) do
      get "/not_limited"
    end

    it "should have x-RateLimit-Limit" do
      expect(last_response.header).not_to include "x-RateLimit-Limit"
    end

    it "should have x-RateLimit-Remaining" do
      expect(last_response.header).not_to include "x-RateLimit-Remaining"
    end

    it "should have x-RateLimit-Reset" do
      expect(last_response.header).not_to include "x-RateLimit-Reset"
    end
  end
end
