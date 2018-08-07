# frozen_string_literal: true
require "spec_helper"

describe "Frequency/rph rule request" do
  include Rack::Test::Methods

  it "should be allowed if not exceed 1 request per min" do
    get "/freq/rph", {}, "HTTP_ACCEPT" => "text/html"
    expect(last_response.body).to show_allowed_response
  end

  it "should not be allowed if exceed 1 request per min" do
    2.times { get "/freq/rph", {}, "HTTP_ACCEPT" => "text/html" }
    expect(last_response.body).to show_not_allowed_response
  end
end
