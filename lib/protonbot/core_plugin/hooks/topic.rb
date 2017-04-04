hook(type: :utopic) do |dat|
  dat[:plug].users[dat[:nick]] = dat[:plug].users[dat[:nick]] or {}
  u = dat[:plug].users[dat[:nick]]
  u[:nick] = dat[:nick]
  u[:user] = dat[:user]
  u[:host] = dat[:host]
  dat[:plug].chans[dat[:chan]][:topic] = dat[:topic]
end