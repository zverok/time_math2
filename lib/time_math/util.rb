module TimeMath
  # @private
  module Util
    # all except :week
    NATURAL_UNITS = [:year, :month, :day, :hour, :min, :sec].freeze
    EMPTY_VALUES = [nil, 1, 1, 0, 0, 0].freeze

    module_function

    def timey?(val)
      [Time, DateTime, Date].any? { |cls| val.is_a?(cls) }
    end

    def merge(tm, attrs = {})
      hash_to_tm(tm, tm_to_hash(tm).merge(attrs))
    end

    def array_to_tm(origin, *components)
      components = EMPTY_VALUES.zip(components).map { |d, c| c || d }

      case origin
      when Time
        Time.new(*components, origin.utc_offset)
      when DateTime
        DateTime.new(*components, origin.zone)
      when Date
        Date.new(*components.first(3))
      else
        raise ArgumentError, "Expected Time, Date or DateTime, got #{origin.class}"
      end
    end

    def tm_to_array(tm)
      case tm
      when Time, DateTime
        [tm.year, tm.month, tm.day, tm.hour, tm.min, tm.sec]
      when Date
        [tm.year, tm.month, tm.day]
      else
        raise ArgumentError, "Expected Time, Date or DateTime, got #{tm.class}"
      end
    end

    def tm_to_hash(tm)
      Hash[*NATURAL_UNITS.flat_map { |s| [s, tm.send(s)] }]
    end

    def hash_to_tm(origin, hash)
      components = NATURAL_UNITS.map { |s| hash[s] || 0 }
      array_to_tm(origin, *components)
    end
  end
end
