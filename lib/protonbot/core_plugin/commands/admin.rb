@key = nil

core.help_add('owner', 'key', 'key [key]', 'Generates unique key. If correct key is ' +
  'provided, gives owner privileges')
cmd(cmd: 'key') do |dat|
  if !dat[:split].empty?
    if dat[:split][0] == @key && !@key.nil?
      dat.reply "#{dat[:nick]}: given key is valid! You are an owner now!"
      addperm(dat[:plug], dat[:host], 'owner')
    elsif dat[:split][0] == dat[:plug].conf['uniq_key'] && dat[:plug].conf['uniq_key']
      dat.reply "#{dat[:nick]}: given key is valid! You are an owner now!"
      addperm(dat[:plug], dat[:host], 'owner')
    else
      dat.reply "#{dat[:nick]}: given key is invalid!"
    end
    @key = nil
  else
    @key = Random.rand(44**44..55**55).to_s(36)
    log.debug 'Use this key to auth yourself: ' + @key
    dat.reply "#{dat[:nick]}: generated your key and outputted to console!" \
              ' Use `key <key>` to make yourself owner!'
  end
end

core.help_add('owner', 'rb', 'rb {code}', 'Evaluates given ruby code')
cmd(cmd: 'rb') do |dat|
  if dat[:split]
    begin
      out = eval(dat[:split].join(' ')).inspect
      dat.reply "%BOutput%N: #{out}"
    rescue StandardError, SyntaxError => e
      dat.reply "E: #{e.class} => #{e.message}"
    end
  else
    dat.reply '%BOutput%N: nil'
  end
end.perm!('eval')

core.help_add('owner', 'exec', 'exec {command}', 'Executes given command')
cmd(cmd: 'exec') do |dat|
  if dat[:split]
    stdout, stderr, status = Open3.capture3(dat[:split].join(' '))
    STDERR.puts stderr
    if status.success?
      dat.reply stdout
    else
      dat.nreply 'Err: ' + stderr
    end
  end
end.perm!('exec')

core.help_add('owner', 'raw', 'raw {message}', 'Sends raw message to an IRC server')
cmd(cmd: 'raw') do |dat|
  dat[:plug].write(dat[:split].join(' '))
end.perm!('raw')

core.help_add('admin', 'nick', 'nick <nick>', 'Changes nick')
cmd(cmd: 'nick') do |dat|
  if dat[:split].empty?
    dat.nreply ProtonBot::Messages::NOT_ENOUGH_PARAMETERS
  else
    dat[:plug].change_nick(dat[:split][0])
  end
end.perm!('nick')

core.help_add('admin', 'msg', 'msg <target> <message>', 'Sends given message to target')
cmd(cmd: 'msg') do |dat|
  if dat[:split].empty?
    dat.nreply ProtonBot::Messages::NOT_ENOUGH_PARAMETERS
  else
    dat[:plug].privmsg(dat[:split][0], dat[:split][1, dat[:split].length].join(' '))
  end
end.perm!('msg')

core.help_add('admin', 'ctcp', 'ctcp <target> <message>', 'Sends given ctcp to target')
cmd(cmd: 'ctcp') do |dat|
  if dat[:split].empty?
    dat.nreply ProtonBot::Messages::NOT_ENOUGH_PARAMETERS
  else
    dat[:plug].ctcp(dat[:split][0], dat[:split][1, dat[:split].length].join(' '))
  end
end.perm!('ctcp')

core.help_add('admin', 'action', 'action [target] <message>', 'Sends given ctcp ACTION to target')
cmd(cmd: 'action') do |dat|
  if dat[:split].empty?
    dat.nreply ProtonBot::Messages::NOT_ENOUGH_PARAMETERS
  else
    if %w(! + # &).include? dat[:split][0][0]
      dat[:plug].action(dat[:split][0], dat[:split][1, dat[:split].length].join(' '))
    else
      dat[:plug].action(dat[:target], dat[:split][0, dat[:split].length].join(' '))
    end
  end
end.perm!('ctcp')

core.help_add('admin', 'notice', 'notice <target> <message>', 'Sends given notice to target')
cmd(cmd: 'notice') do |dat|
  if dat[:split].empty?
    dat.nreply ProtonBot::Messages::NOT_ENOUGH_PARAMETERS
  else
    dat[:plug].notice(dat[:split][0], dat[:split][1, dat[:split].length].join(' '))
  end
end.perm!('notice')

core.help_add('admin', 'nctcp', 'nctcp <target> <message>', 'Sends given nctcp to target')
cmd(cmd: 'nctcp') do |dat|
  if dat[:split].empty?
    dat.nreply ProtonBot::Messages::NOT_ENOUGH_PARAMETERS
  else
    dat[:plug].nctcp(dat[:split][0], dat[:split][1, dat[:split].length].join(' '))
  end
end.perm!('nctcp')

core.help_add('admin', 'flushq', 'flushq', 'Flushes queue')
cmd(cmd: 'flushq') do |dat|
  dat[:plug].queue.clear
  dat.nreply 'Write queue is empty now!'
end.perm!('flushq')

core.help_add('owner', 'r', 'r', 'Reloads all plugins')
hook(type: :command, cmd: 'r') do |dat|
  dat[:bot].log.info 'Reload: START'
  dat[:bot].plugins_unload
  dat[:bot].plugins_load
  dat[:bot].log.info 'Reload: END'
  dat.nreply 'Done!'
end.perm!('reload')
