# encoding: utf-8
require 'simplecov'
SimpleCov.start

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
