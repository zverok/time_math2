require './lib/time_math/version'

Gem::Specification.new do |s|
  s.name     = 'time_math2'
  s.version  = TimeMath::VERSION
  s.authors  = ['Victor Shepelev']
  s.email    = 'zverok.offline@gmail.com'
  s.homepage = 'https://github.com/zverok/time_math2'

  s.summary = 'Easy time math'
  s.description = <<-EOF
    TimeMath is small, no-dependencies library attemting to make work with
    time units easier. It provides you with simple, easy remembered API, without
    any monkey patching of core Ruby classes, so it can be used alongside
    Rails or without it, for any purpose.
  EOF
  s.licenses = ['MIT']

  s.required_ruby_version = '>= 2.1.0'

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

  s.add_development_dependency 'rubocop', '~> 0.65.0'
  s.add_development_dependency 'rspec', '>= 3'
  s.add_development_dependency 'rubocop-rspec', '>= 1.17.1'
  s.add_development_dependency 'rspec-its', '~> 1'
  s.add_development_dependency 'simplecov', '~> 0.9'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rubygems-tasks'
  s.add_development_dependency 'yard'
end
