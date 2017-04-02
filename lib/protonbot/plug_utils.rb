class ProtonBot::Plug
  # Sends WHOIS message to the server
  # @param nick [String]
  # @return [Plug] self
  def whois(nick)
    write("WHOIS #{nick}")
    self
  end

  # Gets hostname for given nickname using WHOIS and event lock
  # @param nick [String]
  # @return [String] host
  def gethost(nick)
    if @users[nick] and @users[nick][:host]
      @users[nick][:host]
    else
      Thread.new do
        sleep(1)
        whois(nick)
      end
      wait_for(type: :code_whoisuser, nick: nick)
    end
    @users[nick][:host]
  end

  # Gets username for given nickname using WHOIS and event lock
  # @param nick [String]
  # @return [String] user
  def getuser(nick)
    if @users[nick] and @users[nick][:user]
      @users[nick][:user]
    else
      Thread.new do
        sleep(1)
        whois(nick)
      end
      wait_for(type: :code, code: ProtonBot::Numeric::WHOISUSER)
      @users[nick][:user]
    end
  end

  # Changes current nick to given. If successful, `unick` event will be emitted
  # @param to [String]
  # @return [Plug] self
  def change_nick(to)
    write("NICK #{to}")
    self
  end

  # Joins given channel and uses password if it's provided
  # @param chan [String]
  # @param pass [String] Password
  # @return [Plug] self
  def join(chan, pass = '')
    write("JOIN #{chan} #{pass}")
    self
  end

  # Parts given channel with given reason
  # @param chan [String]
  # @param reason [String]
  def part(chan, reason = 'Parting...')
    write("PART #{chan} :#{reason}")
    self
  end

  # Sends message to given target. Splits it each 399 bytes.
  # @param target [String]
  # @param msg [String]
  # @return [Plug] self
  def privmsg(target, msg)
    self.class.ssplit(self.class.process_colors(msg)).each do |m|
      write("PRIVMSG #{target} :\u200B#{m}")
    end
    self
  end

  # Sends notice to given target. Splits it each 399 bytes.
  # @param target [String]
  # @param msg [String]
  # @return [Plug] self
  def notice(target, msg)
    self.class.ssplit(self.class.process_colors(msg)).each do |m|
      write("NOTICE #{target} :\u200B#{m}")
    end
    self
  end

  # Sends CTCP to given target.
  # @param target [String]
  # @param msg [String]
  # @return [Plug] self
  def ctcp(target, msg)
    write("PRIVMSG #{target} :\x01#{self.class.process_colors(msg)}\x01")
    self
  end

  # Sends NCTCP to given target.
  # @param target [String]
  # @param msg [String]
  # @return [Plug] self
  def nctcp(target, msg)
    write("NOTICE #{target} :\x01#{self.class.process_colors(msg)}\x01")
    self
  end

  # Invites user to given channel
  # @param chan [String]
  # @param nick [String]
  # @return [Plug] self
  def invite(chan, nick)
    write("INVITE #{nick} #{chan}")
    self
  end

  # Sets mode on given user at given channel
  # @param chan [String]
  # @param nick [String]
  # @param mode [String]
  # @return [Plug] self
  def usermode(chan, nick, mode)
    write("MODE #{chan} #{mode} #{nick}")
    self
  end

  # Sets mode on given channel
  # @param chan [String]
  # @param mode [String]
  # @return [Plug] self
  def chanmode(chan, mode)
    write("MODE #{chan} #{mode}")
    self
  end

  # Sets quiet on given user at given channel
  # @param chan [String]
  # @param nick [String]
  # @return [Plug] self
  def quiet(chan, nick)
    usermode(chan, nick, '+q')
    self
  end

  # Removes quiet on given user at given channel
  # @param chan [String]
  # @param nick [String]
  # @return [Plug] self
  def unquiet(chan, nick)
    usermode(chan, nick, '-q')
    self
  end

  # Sets ban on given user at given channel
  # @param chan [String]
  # @param nick [String]
  # @return [Plug] self
  def ban(chan, nick)
    usermode(chan, nick, '+b')
    self
  end

  # Removes ban on given user at given channel
  # @param chan [String]
  # @param nick [String]
  # @return [Plug] self
  def unban(chan, nick)
    usermode(chan, nick, '-b')
    self
  end

  # Sets excempt on given user at given channel
  # @param chan [String]
  # @param nick [String]
  # @return [Plug] self
  def excempt(chan, nick)
    usermode(chan, nick, '+e')
    self
  end

  # Removes excempt on given user at given channel
  # @param chan [String]
  # @param nick [String]
  # @return [Plug] self
  def unexcempt(chan, nick)
    usermode(chan, nick, '-e')
    self
  end

  # Ops given user at given channel
  # @param chan [String]
  # @param nick [String]
  # @return [Plug] self
  def op(chan, nick)
    usermode(chan, nick, '+o')
    self
  end

  # Deops given user at given channel
  # @param chan [String]
  # @param nick [String]
  # @return [Plug] self
  def deop(chan, nick)
    usermode(chan, nick, '-o')
    self
  end

  # Voices given user at given channel
  # @param chan [String]
  # @param nick [String]
  # @return [Plug] self
  def voice(chan, nick)
    usermode(chan, nick, '+v')
    self
  end

  # Devoices on given user at given channel
  # @param chan [String]
  # @param nick [String]
  # @return [Plug] self
  def devoice(chan, nick)
    usermode(chan, nick, '-v')
    self
  end

  # Kicks given user from given channel
  # @param chan [String]
  # @param nick [String]
  # @return [Plug] self
  def kick(chan, nick, reason = 'Default Kick Reason')
    write("KICK #{chan} #{nick} :#{reason}")
    self
  end

  # Removes given user from given channel
  # @param chan [String]
  # @param nick [String]
  # @return [Plug] self
  def remove(chan, nick, reason = 'Default Remove Reason')
    write("REMOVE #{chan} #{nick} :#{reason}")
    self
  end
end
