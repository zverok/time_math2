# encoding: utf-8
require 'simplecov'
require 'coveralls'
require 'rspec/its'
require 'yaml'

Coveralls.wear!

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  [SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter]
)

SimpleCov.start do
  add_filter 'spec'
  minimum_coverage_by_file 95
end

$:.unshift 'lib'
require 'time_math'

def load_fixture(name)
  YAML.load(File.read("spec/fixtures/#{name}.yml"))
end
