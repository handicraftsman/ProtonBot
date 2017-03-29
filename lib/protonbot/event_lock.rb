# Event lock. Locks current thread until matching event is emitted
# @!attribute [r] plug
#  @return [Plug] Plug
# @!attribute [r] pattern
#  @return [Hash<Symbol>] Pattern
class ProtonBot::EventLock
  attr_reader :plug, :pattern

  # @param plug [Plug]
  # @param pattern [Hash<Symbol>]
  def initialize(plug, pattern)
    @plug = plug
    @plug.event_locks << self
    @pattern = pattern
    @unlock = false
    sleep(0.01) until @unlock
  end

  # Unlocks current thread
  # @return [NilClass]
  def unlock
    @unlock = true
    nil
  end
end
