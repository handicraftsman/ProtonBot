core.help_add('cross', 'as', 'as <nickname> {message}', 'Processes given message as given user')
cmd(cmd: 'as', perm_crossuser: true) do |dat|
  nick = dat[:split][0]
  if dat[:plug].users[nick]
    user = dat[:plug].getuser(nick)
    host = dat[:plug].gethost(nick)
    message = dat[:split][1..dat[:split].length - 1].join(' ')
    dat[:plug].emit(dat.merge(type: :privmsg, nick: nick, user: user, host: host,
                              message: message, target: dat[:target], reply_to: dat[:reply_to]))
  else
    dat.nreply 'No such user!'
  end
end

core.help_add('cross', 'at', 'at <channel> {message}', 'Processes given message at given channel')
cmd(cmd: 'at', perm_crossuser: true) do |dat|
  chan = dat[:split][0]
  if dat[:plug].chans[chan]
    nick = dat[:nick]
    user = dat[:plug].getuser(nick)
    host = dat[:plug].gethost(nick)
    message = dat[:split][1..dat[:split].length - 1].join(' ')
    dat[:plug].emit(dat.merge(type: :privmsg, nick: nick, user: user, host: host,
                              message: message, target: chan, reply_to: chan))
  else
    dat.nreply 'No such chan!'
  end
end

core.help_add('cross', 'on', 'on <server> {message}', 'Processes given message on given server')
cmd(cmd: 'on', perm_crossuser: true) do |dat|
  plug = dat[:split][0]
  if bot.plugs[plug] && bot.plugs[plug].running
    message = dat[:split][1..dat[:split].length - 1].join(' ')
    bot.plugs[plug].emit(dat.merge(type: :privmsg, nick: nil, user: nil, host: nil,
                                   message: message, plug: bot.plugs[plug]))
  else
    dat.nreply 'No such plug!'
  end
end
