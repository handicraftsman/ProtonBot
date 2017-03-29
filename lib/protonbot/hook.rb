# Hook. Created by plugins, it's block is called if emitted event matches pattern
# @!attribute [r] pattern
#   @return [Hash<Symbol>] Hook's pattern
# @!attribute [r] block
#   @return [Proc] Block
# @!attribute [r] extra
#   @return [Hash] Extra data. Usually used by hook modifiers
# @!attribute [r] chain
#   @return [Array<Proc>] Proc array. These are executed before calling main block.
#     If any returns false value, main block is not called
class ProtonBot::Hook
  attr_reader :pattern, :block, :extra, :chain

  # @param pattern [Hash<Symbol>]
  # @param block [Proc]
  def initialize(pattern, &block)
    @pattern = pattern
    @block   = block
    @extra   = {}
    @chain   = []
  end
end
