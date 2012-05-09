Rate Limiting
===============


How to use it
----------------

**Adding to Rails 3.x**

> \# config/application.rb
>
> class Application < Rails::Application
>
>   config.middleware.use RateLimiting do |r|
>
>     r.define_rule( :match => '/resource', :type => :fixed, :metric => :rph, :limit => 300 )
>
>   end
>
> end

Rule Options
----------------

**match**

Accepts aimed resource path or Regexp like '/resource' or /\/resource/.*/

**metric**

:rpd  -  Requests per Day

:rph  -  Requests per Hour

:rpm  -  Requests per Minute

**type**

:frequency  -  1 request per (time/limit)

:fixed - limit requests per time



