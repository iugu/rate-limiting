class RateLimiting

  class Rule
    def initialize(options)
      default_options = {
        :match => /.*/,
        :metric => :rph,
        :type => :frequency,
        :limit => 100
      }
      @options = default_options.merge(options)
      
    end

    def match
      @options[:match].class == String ? Regexp.new(@options[:match] + "$") : @options[:match]
    end

    def limit
      (@options[:type] == :frequency ? 1 : @options[:limit])
    end

    def get_expiration
      (Time.now + ( @options[:type] == :frequency ? get_frequency : get_fixed )).strftime("%d%m%y%H%M%S")
    end

    def get_frequency
      case @options[:metric]
      when :rpd
        return (86400/@options[:limit] == 0 ? 1 : 86400/@options[:limit])
      when :rph
        return (3600/@options[:limit] == 0 ? 1 : 3600/@options[:limit])
      when :rpm
        return (60/@options[:limit] == 0 ? 1 : 60/@options[:limit])
      end
    end

    def get_fixed
      case @options[:metric]
      when :rpd
        return 86400
      when :rph
        return 3600
      when :rpm
        return 60
      end
    end
  end


  def initialize(app, &block)
    @app = app
    @rules = []
    @cache = {}
    block.call(self)
  end

  def call(env)
    request = Rack::Request.new(env)
    allowed?(request) ? @app.call(env) : rate_limit_exceeded
  end

  def rate_limit_exceeded
    [403, {"Content-Type" => "text/html"}, ["Rate Limiting Exceeded"]]
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
    else false
    end
  end

  def cache_get(key)
    case
    when cache.respond_to?(:[])
      return cache[key]
    when cache.respond_to?(:get)
      return cache.get(key) || nil
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
    end
  end

  def allowed?(request)
    if rule = find_matching_rule(request)
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
    key = rule.match.to_s + request.ip.to_s
    if cache_has?(key)
      record = cache_get(key)
      if record.split(':')[1] > Time.now.strftime("%d%m%y%H%M%S")
        if record.split(':')[0].to_i < rule.limit
          record = record.gsub(/.*:/, "#{record.split(':')[0].to_i + 1}:")
        else
          return false
        end
      else
        cache_set(key, "1:" + rule.get_expiration)
      end
    else
      cache_set(key, "1:" + rule.get_expiration)
    end
    true
  end
  
end
