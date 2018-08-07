# frozen_string_literal: true
require "rspec"
require "rack/test"
require "rate_limiting"

def test_app
  @test_app ||= double("Test Rack App")
  allow(@test_app).to receive(:call).with(anything).and_return([200, {}, "Test App Body"])
  @test_app
end

def app
  @test_app ||= test_app
  @app ||= RateLimiting.new(@test_app) do |r|
    r.define_rule(match: "/html", limit: 1)
    r.define_rule(match: "/json", metric: :rph, type: :frequency, limit: 60)
    r.define_rule(match: "/xml", metric: :rph, type: :frequency, limit: 60)
    r.define_rule(match: "/token/ip", limit: 1, token: :id, per_ip: true)
    r.define_rule(match: "/token", limit: 1, token: :id, per_ip: false)
    r.define_rule(match: "/fixed/rpm", metric: :rpm, type: :fixed, limit: 1)
    r.define_rule(match: "/fixed/rph", metric: :rph, type: :fixed, limit: 1)
    r.define_rule(match: "/fixed/rpd", metric: :rpd, type: :fixed, limit: 1)
    r.define_rule(match: "/freq/rpm", metric: :rpm, type: :frequency, limit: 1)
    r.define_rule(match: "/freq/rph", metric: :rph, type: :frequency, limit: 60)
    r.define_rule(match: "/freq/rpd", metric: :rpd, type: :frequency, limit: 1440)
    r.define_rule(match: "/header", metric: :rph, type: :frequency, limit: 60)
    r.define_rule(match: "/per_match/.*", metric: :rph, type: :frequency, limit: 60, per_url: false)
    r.define_rule(match: "/per_url/.*", metric: :rph, type: :frequency, limit: 60, per_url: true)
  end
end

RSpec::Matchers.define :show_allowed_response do
  match do |body|
    body.include?("Test App Body")
  end

  failure_message do
    "expected response to show the allowed response"
  end

  failure_message_when_negated do
    "expected response not to show the allowed response"
  end

  description do
    "expected the allowed response"
  end
end

RSpec::Matchers.define :show_not_allowed_response do
  match do |body|
    body.include?("Rate Limit Exceeded")
  end

  failure_message do
    "expected response to show the not allowed response"
  end

  failure_message_when_negated do
    "expected response not to show the not allowed response"
  end

  description do
    "expected the not allowed response"
  end
end
