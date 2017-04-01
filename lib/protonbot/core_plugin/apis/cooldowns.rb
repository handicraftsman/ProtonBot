class ProtonBot::Hook
  # Basic hook modifier for checking cooldowns. Added by core plugin.
  # @param seconds [Integer] Cooldown
  # @param mode [Symbol] :global, :user_local, :target_local, :user_and_target
  # @param verbose [Boolean]
  # @return [Hook] self
  def cooldown!(seconds, mode = :user_and_target, verbose = true)
    self.extra[:cooldown_seconds] = seconds
    self.extra[:cooldown_verbose] = verbose
    if [:global, :user_local, :target_local, :user_and_target].include? mode
      self.extra[:cooldown_mode] = mode
    else
      self.extra[:cooldown_mode] = :user_and_target
    end

    self.chain << proc do |dat, hook|
      lu_sign =
        case hook.extra[:cooldown_mode]
        when :global
          :"last_used_#{dat[:plug].name}"
        when :user_local
          :"last_used_#{dat[:plug].name}_#{dat[:host]}"
        when :target_local
          :"last_used_#{dat[:plug].name}_#{dat[:target]}"
        when :user_and_target
          :"last_used_#{dat[:plug].name}_#{dat[:target]}_#{dat[:host]}"
        end
      if dat[:bot].plugins['core'].getpermsr(dat[:plug], dat[:host]).include? 'nocooldown'
        true
      elsif hook.extra[lu_sign]
        curtime = Time.now.to_i
        cmp = hook.extra[lu_sign] - curtime + hook.extra[:cooldown_seconds]
        if (cmp) <= 0
          hook.extra[lu_sign] = curtime
          true
        else
          dat.nreply("You need to wait %B#{cmp}%N more seconds to use this!") if
            hook.extra[:cooldown_verbose]
          false
        end
      else
        hook.extra[lu_sign] = Time.now.to_i
        true
      end
    end
  end
end