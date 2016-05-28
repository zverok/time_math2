require_relative 'units/base'
require_relative 'units/simple'
require_relative 'units/day'
require_relative 'units/week'
require_relative 'units/month'
require_relative 'units/year'

module TimeMath
  # See {Units::Base} for detailed description of all units functionality.
  module Units
    # @private
    UNITS = {
      sec: Units::Sec.new, min: Units::Min.new, hour: Units::Hour.new,
      day: Units::Day.new, week: Units::Week.new, month: Units::Month.new,
      year: Units::Year.new
    }.freeze

    # @private
    def self.names
      UNITS.keys
    end

    # @private
    def self.get(name)
      UNITS[name] or
        raise ArgumentError, "Unsupported unit: #{name}"
    end
  end
end
