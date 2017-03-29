hook(type: :ukick) do |dat|
  dat[:plug].users[dat[:nick]] = {} unless dat[:plug].users[dat[:nick]]
  u = dat[:plug].users[dat[:nick]]
  u[:nick] = dat[:nick]
  u[:user] = dat[:user]
  u[:host] = dat[:host]

  unless dat[:plug].chans[dat[:channel]]
    dat[:plug].chans[dat[:channel]] = {}
    dat[:plug].chans[dat[:channel]][:users] = []
  end

  dat[:plug].chans[dat[:channel]][:users].delete dat[:target] if
    dat[:plug].chans[dat[:channel]][:users].include? dat[:target]

  dat[:plug].join(dat[:channel]) if dat[:target] == dat[:plug].nick
end
