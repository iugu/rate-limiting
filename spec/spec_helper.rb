require 'rspec'
require 'rack/test'
require 'rate_limiting'

def test_app
  @test_app ||= mock("Test Rack App")
  @test_app.stub!(:call).with(anything()).and_return([200, {}, "Test App Body"])
  @test_app
end

def app
  @test_app ||= test_app
  @app ||= RateLimiting.new(@test_app) do |r| 
    r.define_rule(:match => '/html', :limit => 1)  
    r.define_rule(:match => '/json', :metric => :rph, :type => :frequency, :limit => 60)
    r.define_rule(:match => '/xml', :metric => :rph, :type => :frequency, :limit => 60)
    r.define_rule(:match => '/token', :limit => 1, :token => :id)
    r.define_rule(:match => '/fixed/rpm', :metric => :rpm, :type => :fixed, :limit => 1)
    r.define_rule(:match => '/fixed/rph', :metric => :rph, :type => :fixed, :limit => 1)
    r.define_rule(:match => '/fixed/rpd', :metric => :rpd, :type => :fixed, :limit => 1)
    r.define_rule(:match => '/freq/rpm', :metric => :rpm, :type => :frequency, :limit => 1)
    r.define_rule(:match => '/freq/rph', :metric => :rph, :type => :frequency, :limit => 60)
    r.define_rule(:match => '/freq/rpd', :metric => :rpd, :type => :frequency, :limit => 1440)
  end 
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
