# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'protonbot/version'

Gem::Specification.new do |spec|
  spec.name          = 'protonbot'
  spec.version       = ProtonBot::VERSION
  spec.authors       = ['Nickolay Ilyushin']
  spec.email         = ['nickolay02@inbox.ru']

  spec.summary       = 'An IRC bot library'
  spec.description   = 'Library for writing cross-server IRC bots'
  spec.homepage      = 'https://github.com/handicraftsman/ProtonBot'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.3.0'

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop', '~> 0.47'

  spec.add_runtime_dependency 'pastel', '~> 0.7.1'
  spec.add_runtime_dependency 'tty', '~> 0.6.1'
  spec.add_runtime_dependency 'heliodor', '~> 0.2.0'
end
