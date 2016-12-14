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
  # minimum_coverage_by_file 95 -- coveralls & JRuby doesn't play really well together
end

$:.unshift 'lib'
require 'time_math'

def load_fixture(name, time_class = nil)
  res = YAML.load(File.read("spec/fixtures/#{name}.yml"))
  return res if time_class != Date

  if res.is_a?(Hash) && res.keys.include?(:sec)
    res = limit_units(res, time_class)
  elsif res.is_a?(Hash) && res.keys.include?(:targets)
    res[:targets] = limit_units(res[:targets], time_class)
  elsif res.is_a?(Array) && res.first.is_a?(Hash) && res.first.key?(:unit)
    res = limit_units(res, time_class)
  end
  res
end

NON_DATE_STEPS = [:hour, :min, :sec]

def limit_units(values, time_class)
  return values unless time_class == Date
  case values
  when Array
    if values.all?{|v| v.is_a?(Symbol) }
      values - NON_DATE_STEPS
    elsif values.all?{|v| v.is_a?(Hash) }
      values.reject{|v| NON_DATE_STEPS.include?(v[:unit]) }
    else
      values
    end
  when Hash
    values.reject { |k, v| NON_DATE_STEPS.include?(k) }
  else
    raise ArgumentError, "Can't limit steps for #{values}"
  end
end

# Ruby prior to 2.2 couldn't parse offsets in time
def Time.parse(str)
  dt = DateTime.parse(str)
  Time.new(dt.year, dt.month, dt.day, dt.hour, dt.min, dt.sec + dt.sec_fraction, 3600 * 24 * dt.offset)
end
