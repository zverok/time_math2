# encoding: utf-8
require 'simplecov'
require 'coveralls'
Coveralls.wear!

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  [SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter]
)

SimpleCov.start do
  add_filter 'spec'
end

$:.unshift 'lib'
require 'time_boots'

require 'rspec/its'

require 'yaml'

def load_fixture(name)
  YAML.load(File.read("spec/fixtures/#{name}.yml"))
end

def t(str)
  Time.parse(str)
end

def dt(str)
  DateTime.parse(str)
end
