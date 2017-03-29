hook(type: :ctcp, cmd: 'VERSION') do |dat|
  dat[:plug].nctcp(dat[:nick], %(VERSION ProtonBot v#{ProtonBot::VERSION} on Ruby ) +
    %(v#{RUBY_VERSION}.#{RUBY_PATCHLEVEL}/#{RUBY_PLATFORM} and Heliodor ) +
    %(v#{Gem.loaded_specs['heliodor'].version.version}))
end

hook(type: :ctcp, cmd: 'PING') do |dat|
  dat[:plug].nctcp(dat[:nick], %(PING #{dat[:split][0]}))
end
