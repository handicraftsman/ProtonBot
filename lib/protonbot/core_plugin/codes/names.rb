hook(type: :code, code: @numeric::NAMREPLY) do |dat|
  m = /[=*@] (.+?) :(.+)/.match(dat[:extra])

  unless dat[:plug].chans[m[1]]
    dat[:plug].chans[m[1]] = {}
  end

  unless dat[:plug].chans[m[1]][:collecting]
    dat[:plug].chans[m[1]][:collecting] = true
    dat[:plug].chans[m[1]][:users] = []
  end
  users = m[2].split(' ')
  users.each do |user|
    user = /[@+%&]*(.+)/.match(user)[1]
    dat[:plug].chans[m[1]][:users] << user
    dat[:plug].users[user] = { nick: user }
  end
end

hook(type: :code, code: @numeric::ENDOFNAMES) do |dat|
  m = /(.+?) :.*/.match(dat[:extra])

  dat[:plug].chans[m[1]][:collecting] = false
end
