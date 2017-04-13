# Main bot class. Use it to create the bot
class ProtonBot::Bot
  attr_reader :log, :_log, :dbs, :plugins, :conf, :plugs, :plugthrs, :core, :db_cross

  # @yield Main bot's block. You'll use it for configuring bot.
  def initialize(&block)
    @_log = ProtonBot::Log.new
    @log = @_log.wrap('main')
    @log.info('Hi there!')

    instance_exec(&block)
    @log.info('Processed main block')

    @conf = {}
    configure
    @log.info('Processed config block')

    Dir.mkdir('dbs/') unless File.exist?(File.expand_path('./dbs/'))
    @db_cross = Heliodor::DB.new("dbs/pb-cross.db", true)

    @parr = []
    @plugins = {}
    plugins_load
    @log.info('Processed plugins block')

    @dbs = {}
    @plugs = {}
    @plugthrs = {}
    @conf['servers'].each do |k_, v_|
      k = k_.clone
      v = v_.clone
      @dbs[k] = Heliodor::DB.new("dbs/#{k}.db", true) unless k.nil?
      @plugs[k] = ProtonBot::Plug.new(self, k.clone, v.clone)
      begin
        if v['enabled'] || v['enabled'].nil?
          Thread.new do
            @plugs[k].connect!
          end
        end
      rescue => e
        @plugs[k].log_err(e)
      end
    end

    Signal.trap('INT') do
      @plugs.each do |_k, v|
        @log.info('Stopping...')
        v.write_('QUIT :Stopping...')
        v.running = false
      end
      @_log.stop
      exit
    end

    @plugs.each do |_, p|
      p.thrjoin
    end

    @_log.stop
  end

  def inspect
    %(<#ProtonBot::Bot:#{object_id.to_s(16)}>)
  end

  module Messages
    NOT_ENOUGH_PARAMETERS = 'Not enough parameters!'.freeze
  end
end
