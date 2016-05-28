require_relative 'units/base'
require_relative 'units/simple'
require_relative 'units/day'
require_relative 'units/week'
require_relative 'units/month'
require_relative 'units/year'

module TimeMath
  module Units
    UNITS = {
      sec: Units::Sec.new, min: Units::Min.new, hour: Units::Hour.new,
      day: Units::Day.new, week: Units::Week.new, month: Units::Month.new,
      year: Units::Year.new
    }.freeze

    def Units.names
      UNITS.keys
    end

    def Units.get(name)
      UNITS[name] or
        raise ArgumentError, "Unsupported unit: #{name}"
    end
  end
end
