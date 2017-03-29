class ProtonBot::Bot
  attr_reader :conf

  # @!group Config

  # Default server-config
  DEFAULT_SERVER_CONFIG = {
    'host' => '127.0.0.1',
    'port' => 6667,
    'user' => 'ProtonBot',
    'nick' => 'ProtonBot',
    'rnam' => 'An IRC bot in Ruby',
    'queue_delay' => 0.7,
    'cmdchar' => '\\',
    'encoding' => 'UTF-8',
    'autojoin' => []
  }.freeze

  # @yield Do your config-loading here
  # @see https://github.com/handicraftsman/heliodor/blob/master/config.md
  #   Config-description
  def configure(&block)
    if block
      @configure_block = block
    else
      @configure_block.call if @configure_block
      set 'tsafe', true
      @conf['servers'].each do |k, v|
        @conf['servers'][k] =
          DEFAULT_SERVER_CONFIG.merge(@conf['global'].to_h).merge(v.to_h)
      end
    end
  end

  # @param dat [Hash] Sets config variable to given value
  def gset(dat)
    raise(ArgumentError, '`dat` is not hash!') unless dat.instance_of?(Hash)
    @conf = dat
  end

  # Binds `val` to `key` in `@conf`
  # @param key [Symbol]
  # @param val [Object]
  def set(key, val)
    @conf[key.to_sym] = val
  end
  # @!endgroup
end
