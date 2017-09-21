module TimeMath
  # @private
  module Measure
    PLURALS = {
      year: :years,
      month: :months,
      week: :weeks,
      day: :days,
      hour: :hours,
      min: :minutes,
      sec: :seconds
    }.freeze

    def self.measure(from, to, options = {})
      select_units(options).reverse.inject({}) do |res, unit|
        span, from = Units.get(unit).measure_rem(from, to)
        res.merge(PLURALS[unit] => span)
      end
    end

    def self.select_units(options)
      units = Units.names
      units.delete(:week) if options[:weeks] == false

      if (idx = units.index(options[:upto]))
        units = units.first(idx + 1)
      end

      units
    end
  end
end
