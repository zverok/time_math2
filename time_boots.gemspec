require './lib/time_boots/version'

Gem::Specification.new do |s|
  s.name     = 'time_boots'
  s.version  = TimeBoots::VERSION
  s.authors  = ['Victor Shepelev']
  s.email    = 'zverok.offline@gmail.com'
  s.homepage = 'https://github.com/zverok/time_boots'

  s.summary = 'Easy time steps math'
  s.description = <<-EOF
    TimeBoots is small, no-dependencies library attemting to make time
    steps easier. It provides you with simple, easy remembered API, without
    any monkey patching of core Ruby classes, so it can be used alongside
    Rails or without it, for any purpose.
  EOF
  s.licenses = ['MIT']

  s.files = `git ls-files`.split($RS).reject do |file|
    file =~ /^(?:
    spec\/.*
    |Gemfile
    |Rakefile
    |\.rspec
    |\.gitignore
    |\.rubocop.yml
    |\.travis.yml
    )$/x
  end
  s.require_paths = ["lib"]

  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-its'
end
