class ProtonBot::Hook
  # Basic hook modifier for checking permissions. Added by core plugin.
  # @param perms [String] Permission names
  # @return [Hook] self
  def perm!(*perms)
    self.extra[:needed_perms] = perms
    self.chain << proc do |dat, hook|
      perms = dat[:perms]
      canrun = true
      needed = hook.extra[:needed_perms]
      not_enough = needed - perms
      available = needed - not_enough
      if not_enough == []
        canrun = true
      else
        canrun = false
        available_  = available.map{|i|'%C%GREEN' + i + '%N'}
        not_enough_ = not_enough.map{|i|'%C%RED' + i + '%N'}
        status      = (available_ + not_enough_).join(' ')
        dat.nreply("Not enough permissions to use this! (#{status})")
      end
      canrun
      #
    end
    self
  end
end

@permhash = {
  'owner' => %w(
    reload
    eval
    exec
    raw
    cross
    admin
    perms
  ),
  'admin' => %w(
    joinpart
    nick
    msg
    ctcp
    notice
    nctcp
    flushq
  ),
  'cross' => %w(
    crossuser
    crosschan
    crossplug
  )
}

fun :process_perms do |a|
  out = nil
  loop do
    out = a
    a.each do |i|
      next unless @permhash.keys.include? i
      canrun = true
      @permhash[i].each do |ii|
        canrun = false if a.include? ii
      end
      a += @permhash[i] if canrun
    end
    break if out == a
  end
  out
end

fun :getperms! do |plug, host|
  getperms(plug, host) or []
end

fun :getperms do |plug, host|
  dat = plug.db.query('perms').ensure.select('host' => host).finish
  if dat.empty?
    nil
  else
    dat[0].to_h['perms']
  end
end

fun :hasperm? do |plug, host, perm|
  dat = plug.db.query('perms').ensure.select('host' => host).finish
  perms = dat[0].to_h['perms'] unless dat.empty?
  perms = []              if dat.empty?
  perms.include?(perm) || dat.include?('owner')
end

fun :addperm do |plug, host, perm|
  perms = getperms(plug, host)
  if !perms
    plug.db.query('perms').ensure.insert(
      'host' => host, 'perms' => [perm]
    ).write.finish
  else
    unless perms.include? perm
      plug.db.query('perms').ensure.update(
        { 'host' => host }, 'perms' => (perms + [perm]).uniq
      ).write.finish
    end
  end
end

fun :delperm do |plug, host, perm|
  perms = getperms(plug, host)
  if perms && perms.include?(perm)
    plug.db.query('perms').ensure.update(
      { 'host' => host }, 'perms' => perms - [perm]
    ).write.finish
  end
end

fun :permhash do
  @permhash
end