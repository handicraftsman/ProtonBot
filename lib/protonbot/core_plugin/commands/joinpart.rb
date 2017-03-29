core.help_add('admin', 'join', 'join (chans|sep=,) [pass]', 'Joins given chans')
hook(type: :command, cmd: 'join') do |dat|
  if dat[:split].empty?
    m.nreply 'Not enough parameters!'
  else
    (pass = dat[:split][1]) || ''
    chans = dat[:split][0].split(',')
    chans.each do |chan|
      dat[:plug].join(chan, pass)
    end
  end
end.perm!('joinpart')

core.help_add('admin', 'part', 'part (chans|sep=,) [reason]', 'Parts given chans')
hook(type: :command, cmd: 'part') do |dat|
  if dat[:split].empty?
    dat[:plug].part(dat[:target], '')
  else
    (reason = dat[:split][1]) || ''
    chans = dat[:split][0].split(',')
    chans.each do |chan|
      dat[:plug].part(chan, reason)
    end
  end
end.perm!('joinpart')
