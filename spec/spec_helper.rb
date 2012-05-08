require 'rspec'
require 'rack/test'
require 'rate_limiting'

def test_app
  @test_app ||= mock("Test Rack App")
  @test_app.stub!(:call).with(anything()).and_return([200, {}, "Test App Body"])
  @test_app
end

Spec::Matchers.define :show_allowed_response do
  match do |body|
    body.include?("Test App Body")
  end

  failure_message_for_should do
    "expected response to show the allowed response"
  end

  failure_message_for_should_not do
    "expected response not to show the allowed response"
  end

  description do
    "expected the allowed response"
  end
end

Spec::Matchers.define :show_not_allowed_response do
  match do |body|
    body.include?("Rate Limiting Exceeded")
  end

  failure_message_for_should do
    "expected response to show the not allowed response"
  end

  failure_message_for_should_not do
    "expected response not to show the not allowed response"
  end

  description do
    "expected the not allowed response"
  end
end
