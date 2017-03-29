# Plugin object. Use it to alter bot's behavior
# @see http://www.rubydoc.info/gems/protonbot/file/plugin-demo.md
# @!attribute [r] name
#   @return [String] Plugin's name
# @!attribute [r] version
#   @return [String] Plugin's version
# @!attribute [r] description
#   @return [String] Plugin's description
# @!attribute [r] name
#   @return [String] Plugin's name
# @!attribute [r] hooks
#   @return [Array<Hook>] Plugin's hooks
# @!attribute [rw] bot
#   @return [Bot] Bot
# @!attribute [rw] Log
#   @return [LogWrapper] Log
# @!attribute [rw] path
#   @return [String] Path
# @!attribute [r] core
#   @return [Plugin] Core plugin
class ProtonBot::Plugin
  attr_reader :name, :version, :description, :plugins, :hooks, :core
  attr_accessor :bot, :log, :path

  # @param block [Proc]
  def initialize(&block)
    @hooks = []
    @block = block
    @numeric = ProtonBot::Numeric
  end

  # Starts plugin
  # @return [Plugin] self
  def launch
    @plugins = @bot.plugins
    @core    = @bot.plugins['core']
    instance_exec(&@block)
    raise ProtonBot::PluginError, 'Plugin-name is not set!' unless
      @name
    raise ProtonBot::PluginError, 'Plugin-description is not set!' unless
      @description
    raise ProtonBot::PluginError, 'Plugin-description is not set!' unless
      @description
    log.info("Started plugin `#{@name} v#{@version}` successfully!")
  end

  # Creates hook and returns it
  # @param pattern [Hash<Symbol>]
  # @param block [Proc]
  # @return [Hook] hook
  def hook(pattern = {}, &block)
    h = ProtonBot::Hook.new(pattern, &block)
    @hooks << h
    h
  end

  # Shortcut for `hook(type: :command, ...) {}`
  # @param pattern [Hash<Symbol>]
  # @param block [Proc]
  # @return [Hook] hook
  def cmd(pattern = {}, &block)
    hook(pattern.merge(type: :command), &block)
  end

  # Emits passed event
  # @param dat [Hash<Symbol>]
  def emit(dat = {})
    dat[:plug].emit(dat) if dat[:plug]
  end

  # Emits passed event in other thread
  # @param dat [Hash<Symbol>]
  def emitt(dat = {})
    dat[:plug].emitt(dat) if dat[:plug]
  end

  # Runs given file (.rb is appended automatically)
  # @param fname [String]
  def run(fname)
    if @name == 'Core'
      instance_eval File.read("#{Gem.loaded_specs['protonbot'].lib_dirs_glob}/" \
        "protonbot/core_plugin/#{fname}.rb"), "#{name}/#{fname}.rb"
    else
      instance_exec do
        instance_eval File.read(File.expand_path("#{path}/#{fname}.rb")), "#{name}/#{fname}.rb"
      end
    end
  end

  # Shortcut for `define_singleton_method(...)`
  # @param name [String,Symbol]
  # @param block [Proc]
  def fun(name, &block)
    define_singleton_method(name, &block)
  end

  # @return [String] Output
  def inspect
    %(<#ProtonBot::Plugin:#{object_id.to_s(16)} @name=#{name} @version=#{version}>)
  end
end
