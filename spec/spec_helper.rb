require 'rspec'
require 'rack/test'
require 'rate_limiting'

def test_app
  @test_app ||= mock("Test Rack App")
  @test_app.stub!(:call).and_return([200, {}, "Test App Body"])
end
