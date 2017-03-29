ProtonBot::Plugin.new do
  @name        = 'Core'
  @version     = ProtonBot::VERSION
  @description = 'ProtonBot\'s core plugin'

  run 'apis/index'
  run 'commands/index'
  run 'hooks/index'
  run 'codes/index'
end
