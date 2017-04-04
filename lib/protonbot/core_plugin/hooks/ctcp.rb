hook(type: :ctcp, cmd: 'VERSION') do |dat|
  dat[:plug].nctcp(dat[:nick], %(VERSION ) + 
    %(%B%C%BLUEProtonBot v#{ProtonBot::VERSION}%N ) +
    %(on %B%C%REDRuby v#{RUBY_VERSION}.#{RUBY_PATCHLEVEL}/#{RUBY_PLATFORM}@#{RUBY_ENGINE}#{RUBY_ENGINE_VERSION}%N ) +
    %(and %B%C%YELLOWHeliodor v#{Gem.loaded_specs['heliodor'].version.version}%N))
end

hook(type: :ctcp, cmd: 'PING') do |dat|
  dat[:plug].nctcp(dat[:nick], %(PING #{dat[:split][0]}))
end
