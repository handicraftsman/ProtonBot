class ProtonBot::Bot
  # @!group Plugins

  # Use it to load external plugins. You cannot provide both arguments
  # @param file [String] Filename
  # @param block [Proc]
  # @example
  #   plugin_loader do
  #     plugin('foo') # Will load plugin from ./plugins/foo/main.rb
  #     gem('bar') # Will load plugin from path_to_gem_bar/lib/bar/plugin.rb
  #   end
  # @example
  #   plugin_loader 'foo' # Will load plugin from ./plugins/foo/main.rb
  def plugin_loader(file = nil, &block)
    raise(ArgumentError, 'Both filename and load-block are nil!') if
      file.nil? && block.nil?

    raise(ArgumentError, 'Both filename and load-block are not nil!') if
      !file.nil? && !block.nil?

    if file
      @plugin_loader = lambda do
        load(File.expand_path('./' + file))
      end
    end

    @plugin_loader = block if block
    self
  end

  # Basically clears plugin hash
  # @return [Bot] self
  def plugins_unload
    @parr    = []
    @plugins = {}
    self
  end

  # Loads all plugins by calling `@plugin_loader` and initializing 
  # each plugin
  # @return [Bot] self
  def plugins_load
    core = pluginr "#{Gem.loaded_specs['protonbot'].lib_dirs_glob.split(':')[0]}/protonbot/core_plugin/plugin.rb"
    core.bot  = self
    core.core = core
    core.launch
    @core = core
    @plugins[core.name] = core
    core.log = @_log.wrap("?#{core.name}")
    core.log.info("Started plugin `#{core.name} v#{core.version}` successfully!")
    @plugin_loader.call if @plugin_loader
    @parr.each do |pl|
      pl.bot  = self
      pl.core = @plugins[core.name]
      pl.launch
      @plugins[pl.name] = pl
      pl.log = @_log.wrap("?#{pl.name}")
      pl.log.info("Started plugin `#{pl.name} v#{pl.version}` successfully!")
    end
    self
  end

  # Loads given plugin by name
  # @param dat [String] Plugin name in file system
  # @return [Bot] self
  def plugin(dat)
    pl = nil
    if dat.instance_of? Array
      dat.each do |i|
        pl = pluginr(File.expand_path("plugins/#{i}/plugin.rb"))
        raise ProtonBot::PluginError, "`plugins/#{i}/plugin.rb` did not return plugin!" unless
          pl.instance_of? ProtonBot::Plugin
      end
    elsif dat.instance_of? String
      pl = pluginr(File.expand_path("plugins/#{dat}/plugin.rb"))
      raise ProtonBot::PluginError, "`plugins/#{dat}/plugin.rb` did not return plugin!" unless
        pl.instance_of? ProtonBot::Plugin
    else
      raise ArgumentError, 'Unknown type of `dat` plugin! Use Array or String!'
    end
    @parr << pl
    self
  end

  # Loads plugin from gem
  # @param gemname [String] Name of gem
  # @return [Bot] self
  def gem(gemname)
    if Gem.loaded_specs[gemname]
      require gemname.gsub(/-/, '/')
      path = "#{Gem.loaded_specs[gemname].lib_dirs_glob.split(':')[0]}/" \
        "#{gemname.gsub(/-/, '/')}/plugin.rb"
      if File.exist? path
        pl = pluginr(path)
        raise ProtonBot::PluginError, "`#{path}` did not return plugin!" unless
          pl.instance_of? ProtonBot::Plugin
        @parr << pl
      else
        raise IOError, "No such file or directory: #{path}"
      end
    else
      raise ArgumentError, "No such gem: #{gemname}"
    end
    self
  end

  # Loads plugins by array of strings. If first char of item is period,
  # then plugin is loaded from gem
  # @param plugins [Array<String>]
  # @return [Bot] self
  def plugin_array(arr)
    arr.each do |pl|
      if pl[0] == '.'
        gem pl[1,pl.length-1]
      else
        plugin pl
      end
    end
  end

  # Loads plugin by path
  # @param path [String] Path
  # @return [Plugin] Loaded plugin
  def pluginr(path)
    if File.exist? path
      pl = eval(File.read(path), nil, %r{.*/(.+/.+)}.match(path)[1])
      pl.path = File.dirname(path)
      pl
    else
      raise IOError, 'No such file or directory: #{path}'
    end
  end

  # @!endgroup
end
