class ProtonBot::Hook
  def cooldown!(seconds, verbose = true)
    self.extra[:cooldown_seconds] = seconds
    self.extra[:cooldown_verbose] = verbose
    self.chain << proc do |dat, hook|
      if dat[:bot].plugins['core'].getpermsr(dat[:plug], dat[:host]).include? 'nocooldown'
        true
      elsif hook.extra[:last_used]
        curtime = Time.now.to_i
        cmp = hook.extra[:last_used] - curtime + hook.extra[:cooldown_seconds]
        if (cmp) <= 0
          hook.extra[:last_used] = curtime
          true
        else
          dat.nreply("You need to wait %B#{cmp}%N more seconds to use this!")
          false
        end
      else
        hook.extra[:last_used] = Time.now.to_i
        true
      end
    end
  end
end