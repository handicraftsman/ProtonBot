hook(type: :unick) do |dat|
  u = dat[:plug].users[dat[:nick]].clone
  dat[:plug].users.delete(dat[:nick])
  dat[:plug].users[dat[:to]] = u
  u[:nick] = dat[:to]
  u[:user] = dat[:user]
  u[:host] = dat[:host]

  dat[:plug].nick = dat[:to] if dat[:nick] == dat[:plug].nick
end