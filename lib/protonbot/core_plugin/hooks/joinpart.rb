hook(type: :ujoin) do |dat|
  dat[:plug].users[dat[:nick]] = {} unless dat[:plug].users[dat[:nick]]
  u = dat[:plug].users[dat[:nick]]
  u[:nick] = dat[:nick]
  u[:user] = dat[:user]
  u[:host] = dat[:host]

  unless dat[:plug].chans[dat[:channel]]
    dat[:plug].chans[dat[:channel]] = {}
    dat[:plug].chans[dat[:channel]][:users] = []
  end

  dat[:plug].chans[dat[:channel]][:users] << u[:nick] unless
    dat[:plug].chans[dat[:channel]][:users].include? u[:nick]
end

hook(type: :upart) do |dat|
  dat[:plug].users[dat[:nick]] = {} unless dat[:plug].users[dat[:nick]]
  u = dat[:plug].users[dat[:nick]]
  u[:nick] = dat[:nick]
  u[:user] = dat[:user]
  u[:host] = dat[:host]

  unless dat[:plug].chans[dat[:channel]]
    dat[:plug].chans[dat[:channel]] = {}
    dat[:plug].chans[dat[:channel]][:users] = []
  end

  dat[:plug].chans[dat[:channel]][:users].delete u[:nick] if
    dat[:plug].chans[dat[:channel]][:users].include? u[:nick]

  if dat[:nick] == dat[:plug].nick && /requested by .*/.match(dat[:message])
    dat[:plug].join(dat[:channel])
  elsif dat[:nick] == dat[:plug].nick
    dat[:plug].chans.delete(dat[:channel])
  end
end

hook(type: :uquit) do |dat|
  dat[:plug].chans.each do |chan|
    chan[:users].delete(dat[:nick]) if chan[:users]
  end
  dat[:plug].users.delete(dat[:nick])
end