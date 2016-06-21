require 'time'

# TimeMath is a small library for easy time units arithmetics (like "floor
# the timestamp to the nearest hour", "advance the time value by 3 days"
# and so on).
#
# It has clean and easy-to-remember API, just like this:
#
# ```ruby
# TimeMath.day.floor(Time.now)
# # or
# TimeMath[:day].floor(Time.now)
# ```
#
# `TimeMath[unit]` and `TimeMath.<unit>` give you an instance of
# time unit, which incapsulates most of the functionality. Refer to
# {Units::Base} to see what you can get of it.
#
module TimeMath
  require_relative './time_math/units'
  require_relative './time_math/op'
  require_relative './time_math/sequence'
  require_relative './time_math/measure'
  require_relative './time_math/span'
  require_relative './time_math/resamplers'
  require_relative './time_math/util'

  # rubocop:disable Style/ModuleFunction
  extend self
  # rubocop:enable Style/ModuleFunction

  # List all unit names known.
  #
  # @return [Array<Symbol>]
  def units
    Units.names
  end

  # Main method to do something with TimeMath. Returns an object
  # representing some time measurement unit. See {Units::Base} documentation
  # to know what you can do with it.
  #
  # @return [Units::Base]
  def [](unit)
    Units.get(unit)
  end

  # @!method sec
  #   Shortcut to get second unit.
  #   @return [Units::Base]
  #
  # @!method min
  #   Shortcut to get minute unit.
  #   @return [Units::Base]
  #
  # @!method hour
  #   Shortcut to get hour unit.
  #   @return [Units::Base]
  #
  # @!method day
  #   Shortcut to get day unit.
  #   @return [Units::Base]
  #
  # @!method week
  #   Shortcut to get week unit.
  #   @return [Units::Base]
  #
  # @!method month
  #   Shortcut to get month unit.
  #   @return [Units::Base]
  #
  # @!method year
  #   Shortcut to get year unit.
  #   @return [Units::Base]
  #
  Units.names.each do |unit|
    define_method(unit) { Units.get(unit) }
  end

  # Measures distance between two time values in all units at once.
  #
  # Just like this:
  #
  # ```ruby
  # birthday = Time.parse('1983-02-14 13:30')
  #
  # TimeMath.measure(birthday, Time.now)
  # # => {:years=>33, :months=>3, :weeks=>2, :days=>0, :hours=>1, :minutes=>25, :seconds=>52}
  # ```
  #
  # @param from [Time,DateTime]
  # @param to [Time,DateTime]
  # @param options [Hash] options
  # @option options [Boolean] :weeks pass `false` to exclude weeks from calculation;
  # @option options [Symbol] :upto pass max unit to use (e.g. if you'll
  #   pass `:day`, period would be measured in days, hours, minutes and seconds).
  #
  # @return [Hash]
  def measure(from, to, options = {})
    Measure.measure(from, to, options)
  end
end

def TimeMath(*arguments) # rubocop:disable Style/MethodName
  TimeMath::Op.new(*arguments)
end
