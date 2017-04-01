core.help_add('basic', 'ping', 'ping', 'Ping!')
cmd(cmd: 'ping') do |dat|
  dat.reply("#{dat[:nick]}: pong!")
end.cooldown!(5)

core.help_add('basic', 'echo', 'echo', 'Sends given message back')
cmd(cmd: 'echo') do |dat|
  dat.reply("#{dat[:split].join(' ')}")
end.cooldown!(5)
