require 'time'

require_relative './time_math/units'
require_relative './time_math/sequence'
require_relative './time_math/measure'
require_relative './time_math/span'

module TimeMath
  # rubocop:disable Style/ModuleFunction
  extend self
  # rubocop:enable Style/ModuleFunction

  def units
    Units.names
  end

  def [](unit)
    Units.get(unit)
  end

  Units.names.each do |unit|
    define_method(unit) { Units.get(unit) }
  end

  def measure(from, to, options = {})
    Measure.measure(from, to, options)
  end
end
