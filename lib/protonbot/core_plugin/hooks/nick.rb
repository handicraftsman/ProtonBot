hook(type: :unick) do |dat|
  dat[:plug].chans.each do |k, chan|
    if chan[:users] and chan[:users].include? dat[:nick]
      emit(dat.merge(type: :unickc, channel: k))
    end
  end

  u = nil
  if dat[:plug].users[dat[:nick]]
    u = dat[:plug].users[dat[:nick]].clone
    dat[:plug].users.delete(dat[:nick]) 
    dat[:plug].users[dat[:to]] = u
  else
    u = {}
    dat[:plug].users[dat[:nick]] = u
  end
  u[:nick] = dat[:to]
  u[:user] = dat[:user]
  u[:host] = dat[:host]

  dat[:plug].nick = dat[:to] if dat[:nick] == dat[:plug].nick
end