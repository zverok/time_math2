module TimeMath
  # @private
  module Util
    COMMON_UNITS = %i[year month day hour min sec].freeze
    NATURAL_UNITS = [*COMMON_UNITS, :subsec].freeze
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
      fix_month_day(components)

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
      NATURAL_UNITS.map { |s| [s, extract_component(tm, s)] }.to_h
    end

    def hash_to_tm(origin, hash)
      components = NATURAL_UNITS[0..-2].map { |s| hash[s] || 0 }
      components[-1] += (hash[:subsec] || hash[:sec_fraction] || 0)
      array_to_tm(origin, *components)
    end

    DAYS_IN_MONTH = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31].freeze

    def fix_month_day(components)
      return if components[2].nil? || components[1].nil?
      days_in_month =
        if components[1] == 2 && components[0] && Date.gregorian_leap?(components[0])
          29
        else
          DAYS_IN_MONTH[components[1]]
        end
      components[2] = [components[2], days_in_month].min
    end

    private

    module_function

    def extract_component(tm, component)
      case component
      when :subsec, :sec_fraction
        tm.is_a?(Time) ? tm.subsec : tm.send(:sec_fraction)
      when *COMMON_UNITS
        tm.send(component)
      end
    end
  end
end
