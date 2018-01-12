[![Build status](https://img.shields.io/travis/iugu/rate-limiting.svg)](https://travis-ci.org/iugu/rate-limiting)
[![Gem version](https://img.shields.io/gem/v/rate-limiting.svg)](https://rubygems.org/gems/rate-limiting)
[![Downloads](https://img.shields.io/gem/dt/rate-limiting.svg)](https://rubygems.org/gems/rate-limiting)

Rate Limiting
===============

Rate Limiting is a rack middleware that rate-limit HTTP requests in many different ways.
It provides tools for creating rules which can rate-limit routes separately.



How to use it
----------------

**Adding to Rails 3.x**

Gemfile

     gem 'rate-limiting'

config/application.rb

     require "rate_limiting"

     class Application < Rails::Application

       config.middleware.use RateLimiting do |r|

         # Add your rules here, ex:

         r.define_rule( :match => '/resource', :type => :fixed, :metric => :rph, :limit => 300 )
         r.define_rule(:match => '/html', :limit => 1)
         r.define_rule(:match => '/json', :metric => :rph, :type => :frequency, :limit => 60)
         r.define_rule(:match => '/xml', :metric => :rph, :type => :frequency, :limit => 60)
         r.define_rule(:match => '/token/ip', :limit => 1, :token => :id, :per_ip => true)
         r.define_rule(:match => '/token', :limit => 1, :token => :id, :per_ip => false)
         r.define_rule(:match => '/fixed/rpm', :metric => :rpm, :type => :fixed, :limit => 1)
         r.define_rule(:match => '/fixed/rph', :metric => :rph, :type => :fixed, :limit => 1)
         r.define_rule(:match => '/fixed/rpd', :metric => :rpd, :type => :fixed, :limit => 1)
         r.define_rule(:match => '/freq/rpm', :metric => :rpm, :type => :frequency, :limit => 1)
         r.define_rule(:match => '/freq/rph', :metric => :rph, :type => :frequency, :limit => 60)
         r.define_rule(:match => '/freq/rpd', :metric => :rpd, :type => :frequency, :limit => 1440)
         r.define_rule(:match => '/header', :metric => :rph, :type => :frequency, :limit => 60)

       end

     end


Rule Options
----------------

### match

Accepts aimed resource path or Regexp like '/resource' or "/resource/.*"

### metric

:rpd  -  Requests per Day

:rph  -  Requests per Hour

:rpm  -  Requests per Minute

### type

:frequency  -  1 request per (time/limit)

:fixed - limit requests per time

Examples:

      r.define_rule(:match => "/resource", :metric => :rph, :type => :frequency, :limit => 3)

      => 1 request every 20 min

      r.define_rule(:match => "/resource", :metric => :rph, :type => :fixed, :limit => 3)

      => 3 request every 60 min


### token

:foo - limit by request parameter 'foo'

### per_ip

Boolean, true = limit by IP

### per_url

Option used when the match option is a Regexp.
If true, it will limit every url catch separately.

Example:

    r.define_rule(:match => '/resource/.*', :metric => :rph, :type => :fixed, :limit => 1, :per_url => true)

This example will let 1 request per hour for each url caught. ('/resource/url1', '/resource/url2', etc...)

Limit Entry Storage
----------------
By default, the record store used to keep track of request matches is a hash stored as a class instance variable in app instance memory. For a distributed or concurrent application, this will not yeild desired results and should be changed to a different store.

Set the cache by calling `set_cache` in the configuration block
```
r.set_store(Rails.cache)
```

Any traditional store will work, including Memcache, Redis, or an ActiveSupport::Cache::Store. Which is the best choice is an application specific decision, but a fast, shared store is highly recommended.

A more robust cache configuration example:
```
store = case
when ENV['REDIS_RATE_LIMIT_URL'].present?
  # use a separate redis DB
  Redis.new(url: ENV['REDIS_RATE_LIMIT_URL'])
when ENV['REDIS_PROVIDER'].present?
  # no separate redis DB available, share primary redis DB
  Redis.new(url: ENV[ENV['REDIS_PROVIDER']])
when (redis = Redis.new) && (redis.client.connect rescue false)
  # a standard redis connection on port 6379 is available
  redis
when Rails.application.config.cache_store != :null_store
  # no redis store is available, use the rails cache
  Rails.cache
else
  # no distributed store available,
  # a class instance variable will be used
  nil
end

r.set_cache(store) if store.present?
Rails.logger.debug "=> Rate Limiting Store Configured: #{r.cache}"
```

Running Tests
----------------

bundle exec rspec spec
