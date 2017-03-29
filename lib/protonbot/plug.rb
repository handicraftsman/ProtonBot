# Plug. This class includes socket, writer and reader threads, user&channel-data,
# API for interacting with server etc.
# @!attribute [r] bot
#   @return [ProtonBot::Bot] Plug's bot.
# @!attribute [r] db
#   @return [Heliodor::DB] Plug's Heliodor-powered database.
#   @see http://www.rubydoc.info/gems/heliodor
# @!attribute [r] sock
#   @return [TCPSocket,SSLSocket] Plug's socket. May be SSL-socket.
# @!attribute [r] rsock
#   @return [TCPSocket] Always non-SSL socket.
# @!attribute [r] is_ssl
#   @return [Boolean] True if connection is SSL-powered
# @!attribute [r] name
#   @return [String] Plug's name.
# @!attribute [r] conf
#   @return [Hash<String>] Config.
# @!attribute [r] rloop
#   @return [Thread] Reader-loop-thread.
# @!attribute [r] wloop
#   @return [Thread] Writer-loop-thread.
# @!attribute [r] log
#   @return [ProtonBot::LogWrapper] Log wrapper.
# @!attribute [r] queue
#   @return [Queue] Queue.
# @!attribute [r] chans
#   @return [Hash<String>] Channel data.
# @!attribute [r] users
#   @return [Hash<String>] User data (by nick).
# @!attribute [r] event_locks
#   @return [Array<EventLock>] Event locks.
# @!attribute [rw] running
#   @return [Boolean] Returns `true` if bot still runs 
#     and processes messages from server.
# @!attribute [r] user
#   @return [String] Plug's username.
# @!attribute [r] nick
#   @return [String] Plug's nickname.
# @!attribute [r] rnam
#   @return [String] Plug's realname.
class ProtonBot::Plug
  attr_reader :bot, :db, :sock, :rsock, :name, :conf, :rloop, :wloop, :log, :queue, :chans, :users,
              :event_locks, :user, :nick, :rnam, :is_ssl
  attr_accessor :running

  # @param bot [Bot]
  # @param name [String]
  # @param conf [Hash<String>]
  def initialize(bot, name, conf)
    @bot         = bot
    @name        = name
    @db          = @bot.dbs[@name]
    @log         = @bot._log.wrap("!#{@name}")
    @conf        = conf
    @nick        = conf['nick']
    @user        = conf['user']
    @rnam        = conf['rnam']
    @sock        = nil
    @running     = false
    @queue       = Queue.new
    @chans       = {}
    @users       = {}
    @event_locks = []
  end

  # Connects to server, introduces and starts reader and writer threads.
  # @return [Plug] self
  def connect!
    if @conf['ssl'] == nil or @conf['ssl'] == false
      @sock = @rsock = TCPSocket.new(@conf['host'], @conf['port'])
      @is_ssl = false
    else
      @rsock = TCPSocket.new(@conf['host'], @conf['port'])
      @ssl_ctx = OpenSSL::SSL::SSLContext.new
      @ssl_ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
      @ssl_ctx.ssl_version = :SSLv23
      @ssl_ctx.cert = OpenSSL::X509::Certificate.new(File.read(File.expand_path(@conf['ssl_crt']))) if
        @conf['ssl_crt']
      @ssl_ctx.key = OpenSSL::PKey::RSA.new(File.read(File.expand_path(@conf['ssl_key']))) if
        @conf['ssl_key']
      @sock = OpenSSL::SSL::SSLSocket.new(@rsock, @ssl_ctx)
      @sock.sync = true
      @sock.connect
      @is_ssl = true
    end

    @running = true

    @rloop = Thread.new { readloop }
    @wloop = Thread.new { writeloop }

    log.info("Started plug `#{name}` successfully!")

    introduce

    @rloop.join
    @wloop.join
    self
  end

  # Logs given error object to cosole
  # @param e [Exception]
  # @return [Plug] self
  def log_err(e)
    @log.error('Error!')
    @log.error("> Message: #{e.message}")
    @log.error('> Backtrace:')
    e.backtrace.each do |i|
      @log.error(">> #{i}")
    end
    self
  end

  # @return [String] out
  def inspect
    %(<#ProtonBot::Plug:#{object_id.to_s(16)} @name=#{name} @bot=#{bot}>)
  end
end
