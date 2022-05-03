require "json"
require "rule"

class RateLimiting

  def initialize(app, &block)
    @app = app
    @logger =  nil
    @rules = []
    @cache = {}
    block.call(self)
  end

  def call(env)
    request = Rack::Request.new(env)
    @logger = env['rack.logger']
    (limit_header = allowed?(request)) ? respond(env, limit_header) : rate_limit_exceeded(env['HTTP_ACCEPT'])
  end

  def respond(env, limit_header)
    status, header, response = @app.call(env)
    (limit_header.class == Hash) ? [status, header.merge(limit_header), response] : [status, header, response]
  end

  def rate_limit_exceeded(accept)
    case accept.gsub(/;.*/, "").split(',')[0]
    when "text/xml"         then message, type  = xml_error("403", "Rate Limit Exceeded"), "text/xml"
    when "application/json" then  message, type  = ["Rate Limit Exceeded"], "application/json"
    else
      message, type  = ["Rate Limit Exceeded"], "text/html"
    end
    [403, {"Content-Type" => type}, message]
  end

  def define_rule(options)
    @rules << Rule.new(options)
  end

  def set_cache(cache)
    @cache = cache
  end

  def cache
    case @cache
      when Proc then @cache.call
      else @cache
    end
  end

  def cache_has?(key)
    case
    when cache.respond_to?(:has_key?)
      cache.has_key?(key)
    when cache.respond_to?(:get)
      cache.get(key) rescue false
    when cache.respond_to?(:exist?)
      cache.exist?(key)
    else false
    end
  end

  def cache_get(key)
    case
    when cache.respond_to?(:[])
      return cache[key]
    when cache.respond_to?(:get)
      return cache.get(key) || nil
    when cache.respond_to?(:fetch)
      return cache.fetch(key)
    end
  end

  def cache_set(key, value)
    case
    when cache.respond_to?(:[])
      begin
        cache[key] = value
      rescue TypeError => e
        cache[key] = value.to_s
      end
    when cache.respond_to?(:set)
      cache.set(key, value)
    when cache.respond_to?(:write)
      begin
        cache.write(key, value)
      rescue TypeError => e
        cache.write(key, value.to_s)
      end
    end
  end

  def logger
    @logger || Rack::NullLogger.new(nil)
  end

  def allowed?(request)
    if rule = find_matching_rule(request)
      logger.debug "[#{self}] #{request.ip}:#{request.path}: Rate limiting rule matched."
      apply_rule(request, rule)
    else
      true
    end
  end

  def find_matching_rule(request)
    @rules.each do |rule|
      return rule if request.path =~ rule.match
    end
    nil
  end

  def apply_rule(request, rule)
    key = rule.get_key(request)
    if cache_has?(key)
      record = cache_get(key)
      logger.debug "[#{self}] #{request.ip}:#{request.path}: Rate limiting entry: '#{key}' => #{record}"
      if (reset = Time.at(record.split(':')[1].to_i)) > Time.now
        # rule hasn't been reset yet
        times = record.split(':')[0].to_i
        cache_set(key, "#{times + 1}:#{reset.to_i}")
        if (times) < rule.limit
          # within rate limit
          response = get_header(times + 1, reset, rule.limit)
        else
          logger.debug "[#{self}] #{request.ip}:#{request.path}: Rate limited; request rejected."
          return false
        end
      else
        response = get_header(1, rule.get_expiration, rule.limit)
        cache_set(key, "1:#{rule.get_expiration.to_i}")
      end
    else
      response = get_header(1, rule.get_expiration, rule.limit)
      cache_set(key, "1:#{rule.get_expiration.to_i}")
    end
    response
  end

  def get_header(times, reset, limit)
    {'x-RateLimit-Limit' => limit.to_s, 'x-RateLimit-Remaining' => (limit - times).to_s, 'x-RateLimit-Reset' => reset.strftime("%d%m%y%H%M%S") }
  end

  def xml_error(code, message)
    "<?xml version=\"1.0\"?>\n<error>\n  <code>#{code}</code>\n  <message>#{message}</message>\n</error>"
  end

end
