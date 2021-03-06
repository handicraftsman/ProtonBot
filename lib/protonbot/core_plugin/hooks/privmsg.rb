fun :privmsg_patch do |h|
  h.define_singleton_method :reply do |msg|
    self[:plug].privmsg(self[:reply_to], msg) if self[:nick]
  end
  h.define_singleton_method :nreply do |msg|
    self[:plug].notice(self[:nick], msg) if self[:nick]
  end
  h
end

hook(type: :privmsg) do |dat|
  # User-data collector
  dat[:plug].users[dat[:nick]] = {} unless dat[:plug].users[dat[:nick]]
  u = dat[:plug].users[dat[:nick]]
  u[:nick] = dat[:nick]
  u[:user] = dat[:user]
  u[:host] = dat[:host]
  dat[:perms] = process_perms(getperms!(dat[:plug], dat[:host]))

  # CTCP
  if dat[:message][0] == "\x01" && dat[:message][-1] == "\x01"
    dat1 = dat.clone
    dat1[:type] = :ctcp
    dat1[:message] = dat1[:message][1..(dat1[:message].length - 2)]
    s = dat1[:message].split(' ')
    dat1[:cmd] = s[0]
    (dat1[:split] = s[1, s.length - 1]) || []
    privmsg_patch(dat1)
    emit(dat1)
  end

  # Command-checker
  cl = dat[:plug].conf['cmdchar'].length
  if dat[:message][0..(cl - 1)] == dat[:plug].conf['cmdchar']
    cmd, *split = dat[:message][cl..-1].split(' ')
    h = dat.merge(type: :command, cmd: cmd, split: split)
    privmsg_patch(h)
    begin
      emit(h)
    rescue => e
      h.nreply("Err: #{e.message} | #{e.backtrace[0]}")
      dat[:plug].log_err(e)
    end
  end
end

hook(type: :notice) do |dat|
  # User-data collector
  dat[:plug].users[dat[:nick]] = {} unless dat[:plug].users[dat[:nick]]
  u = dat[:plug].users[dat[:nick]]
  u[:nick] = dat[:nick]
  u[:user] = dat[:user]
  u[:host] = dat[:host]

  # CTCP
  if dat[:message][0] == "\x01" && dat[:message][-1] == "\x01"
    dat1 = dat.clone
    dat1[:type] = :nctcp
    dat1[:message] = dat1[:message][1..(dat1[:message].length - 2)]
    s = dat1[:message].split(' ')
    dat1[:cmd] = s[0]
    (dat1[:split] = s[1, s.length - 1]) || []
    privmsg_patch(dat1)
    emit(dat1)
  end
end
