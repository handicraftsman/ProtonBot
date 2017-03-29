@help = {}

fun :help_render do |query = nil, ehash = nil|
  if query
    done = nil
    @help.each do |group, items|
      items.each do |item, h|
        next unless item == query
        hook = nil
        @bot.plugins.each do |_, p|
          p.hooks.each do |hk|
            next if hook
            next unless hk
            if hk.pattern[:type] == :command && hk.pattern[:cmd] == h[:name] && hk.extra[:needed_perms]
              hook = hk
            end
          end
        end
        done = 
          if hook && ehash && ehash[:perms]
            perms       = ehash[:perms]
            needed      = hook.extra[:needed_perms]
            not_enough  = needed - perms
            available   = needed - not_enough
            available_  = available.map{|i|'%C%GREEN' + i + '%N'}
            not_enough_ = not_enough.map{|i|'%C%RED' + i + '%N'}
            permstatus  = (available_ + not_enough_).join(' ')
            "%B#{group}/#{item} |%N #{h[:syntax]} %B|%N Perms: #{permstatus} %B|%N #{h[:description]}"
          else
            "%B#{group}/#{item} |%N #{h[:syntax]} %B|%N #{h[:description]}"
          end
      end
    end
    if done
      done
    else
      "No such command: %B#{query}%N"
    end
  else
    'Use %Blist%N command to list all groups. Use %Blist <group>%N ' +
      'command to list all items in group. Use %Bhelp <command>%N to read ' +
      'help for given command. ' +
      'Parameter syntax: %B<required> [optional] {0 or more} (1 or more)%N'
  end
end

fun :help_add do |group, name, syntax, description|
  @help[group] = {} unless @help[group]
  @help[group][name] = {
    name:        name,
    syntax:      syntax,
    description: description
  }
end