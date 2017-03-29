core.help_add('owner', 'perms', 'perms {groups}', 'Lists permissions/permisssion-groups')
cmd(cmd: 'perms') do |dat|
  if dat[:split].empty?
    dat.nreply "Perm groups: #{@permhash.keys.join(', ')}"
  else
    dat[:split].each do |g|
      if @permhash[g]
        dat.nreply "Perms in group %B#{g}%N: #{@permhash[g].join(', ')}"
      else
        dat.nreply "No such group: %B#{g}%N"
      end
    end
  end
end

core.help_add('owner', 'uperms', 'uperms <+|-|?> <user> {perms}', '%B+%N - gives perms. ' \
  '%B-%N - removes perms. %B?%N - checks perms.')
cmd(cmd: 'uperms') do |dat|
  case dat[:split][0]
  when nil
    dat.nreply 'Not enough parameters!'
  when '+'
    if dat[:plug].users[dat[:split][1]]
      dat[:split][2..dat[:split].length-1].each do |perm|
        addperm(dat[:plug], dat[:plug].gethost(dat[:split][1]), perm)
      end
      dat.nreply 'Done!'
    else
      dat.nreply "No such user: #{dat[:split][1]}"
    end
  when '-'
    if dat[:plug].users[dat[:split][1]]
      dat[:split][2..dat[:split].length-1].each do |perm|
        delperm(dat[:plug], dat[:plug].gethost(dat[:split][1]), perm)
      end
      dat.nreply 'Done!'
    else
      dat.nreply "No such user: #{dat[:split][1]}"
    end
  when '?'
    if dat[:plug].users[dat[:split][1]]
      dat.nreply "%B#{dat[:split][1]}%N's perms: " \
        "#{getperms!(dat[:plug], dat[:plug].gethost(dat[:split][1])).join(', ')}"
    else
      dat.nreply "No such user: #{dat[:split][1]}"
    end
  else
    dat.nreply "No such action: #{dat[:split][0]}"
  end
end.perm!('perms')