# Main bot class. Use it to create the bot
class ProtonBot::Bot
  attr_reader :log, :_log, :dbs, :plugins, :conf, :plugs, :plugthrs

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

    @plugins = {}
    plugins_load
    @log.info('Processed plugins block')

    @dbs = {}
    @plugs = {}
    @plugthrs = {}
    Dir.mkdir('dbs/') unless File.exist?(File.expand_path('./dbs/'))
    @conf['servers'].each do |k_, v_|
      k = k_.clone
      v = v_.clone
      @plugthrs[k] = Thread.new do
        @dbs[k] = Heliodor::DB.new("dbs/#{k}.db", true) unless k.nil?
        @plugs[k] = ProtonBot::Plug.new(self, k.clone, v.clone)
        begin
          @plugs[k].connect! if v['enabled'] || v['enabled'].nil?
        rescue => e
          @plugs[k].log_err(e)
        end
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

    @plugthrs.each do |_k, v|
      v.join
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
