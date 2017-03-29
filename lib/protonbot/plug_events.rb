class ProtonBot::Plug
  # Emits passed event - calls first matching hook from each plugin
  # @param dat [Hash] Event hash
  # @return [Plug] self
  def emit(dat = {})
    bot.plugins.each do |_, p|
      worked = []
      p.hooks.each do |h|
        next unless dat >= h.pattern && !worked.include?(h.object_id) && worked.empty?
        canrun = true
        h.chain.each do |l|
          next unless canrun
          canrun = l.call(dat, h)
        end
        worked << h.object_id
        h.block.call(dat) if canrun
      end
      worked = []
    end
    event_locks.each_with_index do |el, k|
      if dat >= el.pattern
        event_locks.delete_at(k)
        el.unlock
      end
    end
    self
  end

  # Emits passed event in new thread
  # @param dat [Hash] Event hash
  # @return [Plug] self
  def emitt(dat = {})
    d = dat.clone
    Thread.new do
      begin
        emit(d)
      rescue => e
        log_err(e)
      end
    end
    self
  end

  # Creates EventLock with given pattern.
  # @param pattern [Hash]
  # @return [Plug] self
  def wait_for(pattern)
    ProtonBot::EventLock.new(self, pattern)
    self
  end
end
