class Rule

  def initialize(options)
    default_options = { 
      :match => /.*/,
      :metric => :rph,
      :type => :frequency,
      :limit => 100,
      :per_ip => true,
      :token => false
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

  def get_key(request)
    key = request.path
    key = key + request.ip.to_s if @options[:per_ip]
    key = key + request.params[@options[:token].to_s] if @options[:token]
    key
  end
end

