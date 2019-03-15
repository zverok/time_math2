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
# See also `TimeMath()` method in global namespace, it is lot of fun!
#
module TimeMath
  require_relative './time_math/units'
  require_relative './time_math/op'
  require_relative './time_math/sequence'
  require_relative './time_math/measure'
  require_relative './time_math/resamplers'
  require_relative './time_math/util'

  module_function

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
    define_singleton_method(unit) { Units.get(unit) }
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
  # @param from [Time,Date,DateTime]
  # @param to [Time,Date,DateTime]
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

# This method helps to create time arithmetics sequence as a value object.
# Some examples:
#
# ```ruby
# # 10 am at first weekday? Easy!
# TimeMath(Time.now).floor(:week).advance(:hour, 10).call
# # => 2016-06-20 10:00:00 +0300
#
# # For several time values? Nothing easier!
# TimeMath(Time.local(2016,1,1), Time.local(2016,2,1), Time.local(2016,3,1)).floor(:week).advance(:hour, 10).call
# # => [2015-12-28 10:00:00 +0200, 2016-02-01 10:00:00 +0200, 2016-02-29 10:00:00 +0200]
#
# # Or, the most fun, you can create complicated operation and call it
# # later:
# op = TimeMath().floor(:week).advance(:hour, 10)
# # => #<TimeMath::Op floor(:week).advance(:hour, 10)>
# op.call(Time.now)
# # => 2016-06-20 10:00:00 +0300
#
# # or even as a lambda:
# times = [Time.local(2016,1,1), Time.local(2016,2,1), Time.local(2016,3,1)]
# times.map(&op)
# # => [2015-12-28 10:00:00 +0200, 2016-02-01 10:00:00 +0200, 2016-02-29 10:00:00 +0200]
# ```
#
# See also {TimeMath::Op} for list of operations available, but basically
# they are all same you can call on {TimeMath::Units::Base}, just pass unit symbol
# as a first argument.
#
# @param arguments time-y value, or list of them, or nothing
#
# @return [TimeMath::Op]
def TimeMath(*arguments) # rubocop:disable Naming/MethodName
  TimeMath::Op.new(*arguments)
end
