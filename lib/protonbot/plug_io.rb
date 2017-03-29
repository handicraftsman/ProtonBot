class ProtonBot::Plug
  # Main read-loop. Reads data from socket and emits event `raw`
  def readloop
    while @running
      if s = @sock.gets
        s = s.force_encoding(@conf['encoding'])
        s = s[0..-3]
        log.info "R > #{s}"
        begin
          emit(type: :raw, raw_data: s.clone, plug: self, db: db, bot: bot, core: bot.plugins['core'])
        rescue => e
          log_err(e)
        end
      else
        @running = false
      end
    end
    log.info 'Connection closed.'
  end

  # Main write-loop. Reads data from queue and sends it to server
  def writeloop
    while @running || !@wqueue.empty?
      s = @queue.pop
      write_(s)
      sleep(@conf['queue_delay'])
    end
  end

  # Adds given message to the queue
  # @param s [String] Message
  # @return [Plug] self
  def write(s)
    @queue << s
    self
  end

  # Sends message to server without using queue.
  # @param s [String] Message
  # @return [Plug] self
  def write_(s)
    s = s.encode(@conf['encoding'], s.encoding)
    @sock.puts s
    log.info "W > #{s}"
  end

  # Sends credentials to server (PASS, NICK, USER).
  def introduce
    write_("PASS #{@conf['pass']}") if @conf['pass']
    write_("NICK #{@conf['nick']}")
    write_("USER #{@conf['user']} 0 * :#{@conf['rnam']}")
  end

  # Splits given string each 399 bytes and on newlines
  # @param string [String]
  # @return [String] Output
  def self.ssplit(string)
    out = []
    arr = string.split("\n\r")
    arr.each do |i|
      items = i.scan(/.{,399}/)
      items.delete('')
      items.each do |i2|
        out << i2
      end
    end
    out
  end

  # Colorizes given string.
  # @param string [String]
  # @return [String] Output
  def self.process_colors(string)
    string
      .gsub("%C%",     "%C?")
      .gsub(",%",      ",?")
      .gsub("%C",      "\x03")
      .gsub("%B",      "\x02")
      .gsub("%I",      "\x10")
      .gsub("%U",      "\x1F")
      .gsub("%N",      "\x0F")
      .gsub("?WHITE",  "0")
      .gsub("?BLACK",  "1")
      .gsub("?BLUE",   "2")
      .gsub("?GREEN",  "3")
      .gsub("?RED",    "4")
      .gsub("?BROWN",  "5")
      .gsub("?PURPLE", "6")
      .gsub("?ORANGE", "7")
      .gsub("?YELLOW", "8")
      .gsub("?LGREEN", "9")
      .gsub("?CYAN"  , "10")
      .gsub("?LCYAN",  "11")
      .gsub("?LBLUE",  "12")
      .gsub("?PINK",   "13")
      .gsub("?GREY",   "14")
      .gsub("?LGREY",  "15")
  end
end
