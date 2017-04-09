hook(type: :code, code: @numeric::WHOISUSER) do |dat|
  m = /(.+?) (.+?) (.+?) \* :.*/.match(dat[:extra])
  dat[:plug].users[m[1]] = {} unless dat[:plug].users[m[1]]
  u = dat[:plug].users[m[1]]
  u[:nick] = m[1]
  u[:user] = m[2]
  u[:host] = m[3]
  emit(dat.merge(type: :code_whoisuser, nick: u[:nick], user: u[:user], host: u[:host]))
end

