Rate Limiting
===============

Rate Limiting is a rack middleware that rate-limit HTTP requests in many different ways. 
It provides tools for creating rules which can rate-limit routes separately.



How to use it
----------------

**Adding to Rails 3.x**

Gemfile

>     gem 'rate-limiting'

config/application.rb

>     require "rate_limiting"
>
>     class Application < Rails::Application
>
>       config.middleware.use RateLimiting do |r|
>
>         # Add your rules here, ex:
>
>         r.define_rule( :match => '/resource', :type => :fixed, :metric => :rph, :limit => 300 )
>
>       end
>
>     end


Rule Options
----------------

**match**

Accepts aimed resource path or Regexp like '/resource' or "/resource/.*"

**metric**

:rpd  -  Requests per Day

:rph  -  Requests per Hour

:rpm  -  Requests per Minute

**type**

:frequency  -  1 request per (time/limit)

:fixed - limit requests per time

Examples: 

      r.define_rule(:match => "/frequency", :metric => :rph, :type => :frequency, :limit => 3)

      => 1 request every 20 min

      r.define_rule(:match => "/resource", :metric => :rph, :type => :fixed, :limit => 3)

      => 3 request every 60 min


**token**

:foo - limit by request parameter 'foo'

**per_ip**

Boolean, true = limit by IP

