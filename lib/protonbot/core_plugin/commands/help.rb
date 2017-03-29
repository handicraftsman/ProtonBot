core.help_add('help', 'help', 'help {commands}', 'Shows help for given commands')
cmd(cmd: 'help') do |dat|
  if dat[:split].empty?
    dat.nreply(help_render)
  else
    dat[:split].each do |i|
      dat.nreply(help_render(i, dat))
    end
  end
end

core.help_add('help', 'list', 'list {groups}', 'Lists groups or items in groups')
cmd(cmd: 'list') do |dat|
  if dat[:split].empty?
    dat.nreply "%BGroups%N: #{@help.keys.join(', ')}"
  else
    dat[:split].each do |i|
      if @help[i]
        dat.nreply "Items in %B#{i}%N: #{@help[i].keys.join(', ')}"
      else
        dat.nreply "No such group: %B#{i}%N"
      end
    end
  end
end