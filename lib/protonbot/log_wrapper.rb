# Log wrapper
# @!attribute [r] log
#   @return [Log] Log
# @!attribute [r] name
#   @return [String] name
class ProtonBot::LogWrapper
  attr_reader :log, :name

  # @param log [Log]
  # @param name [String]
  def initialize(log, name)
    @log  = log
    @name = name
  end

  # @param msg [String]
  # @return [LogWrapper] self
  def info(msg)
    @log.info(msg, @name)
  end

  # @param msg [String]
  # @return [LogWrapper] self
  def debug(msg)
    @log.debug(msg, @name)
  end

  # @param msg [String]
  # @return [LogWrapper] self
  def warn(msg)
    @log.warn(msg, @name)
  end

  # @param msg [String]
  # @return [LogWrapper] self
  def error(msg)
    @log.error(msg, @name)
  end

  # @param msg [String]
  # @return [LogWrapper] self
  # @return [Integer] code
  def crash(msg, code)
    @log.crash(msg, code, @name)
  end

  # @return [String] Output
  def inspect
    %(<#ProtonBot::LogWrapper:#{object_id.to_s(16)} @name='#{@name}') +
      %( @log=#{@log}>)
  end
end
