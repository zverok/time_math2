require './lib/time_boots/version'

Gem::Specification.new do |s|
  s.name = 'time_boots'
  s.version = TimeBoots::VERSION
  s.authors = ['Victor Shepelev']
  s.email = 'zverok.offline@gmail.com'

  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-its'
end
