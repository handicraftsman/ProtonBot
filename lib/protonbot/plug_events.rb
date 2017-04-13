class ProtonBot::Plug
  # Emits passed event - calls first matching hook from each plugin
  # @param dat [Hash] Event hash
  # @return [Plug] self
  def emit(dat = {})
    hooks = []
    bot.plugins.each do |_, p|
      hooks += p.hooks
    end
    hooks = hooks.keep_if do |hook|
      dat >= hook.pattern
    end
    hooks.each do |h|
      canrun = true
      h.chain.each do |l|
        next unless canrun
        canrun = l.call(dat, h)
      end
      h.block.call(dat) if canrun
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
