# frozen_string_literal: true
class Rule
  def initialize(options)
    default_options = {
      match: /.*/,
      metric: :rph,
      type: :frequency,
      limit: 100,
      per_ip: true,
      per_url: false,
      token: false
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
    (Time.now + (@options[:type] == :frequency ? get_frequency : get_fixed))
  end

  def get_frequency
    case @options[:metric]
    when :rpd
      (86_400 / @options[:limit] == 0 ? 1 : 86_400 / @options[:limit])
    when :rph
      (3600 / @options[:limit] == 0 ? 1 : 3600 / @options[:limit])
    when :rpm
      (60 / @options[:limit] == 0 ? 1 : 60 / @options[:limit])
    end
  end

  def get_fixed
    case @options[:metric]
    when :rpd
      86_400
    when :rph
      3600
    when :rpm
      60
    end
  end

  def get_key(request)
    key = (@options[:per_url] ? request.path : @options[:match].to_s)
    key += request.ip.to_s if @options[:per_ip]
    key += request.params[@options[:token].to_s] if @options[:token]
    key
  end
end
