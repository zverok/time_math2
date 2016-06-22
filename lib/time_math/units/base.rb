module TimeMath
  module Units
    # It is a main class representing most of TimeMath functionality.
    # It (or rather its descendants) represents "unit of time" and
    # connected calculations logic. Typical usage:
    #
    # ```ruby
    # TimeMath.day.advance(tm, 5) # advances tm by 5 days
    # ```
    #
    class Base
      # Creates unit of time. Typically you don't need it, as it is
      # easier to do `TimeMath.day` or `TimeMath[:day]` to obtain it.
      #
      # @param name [Symbol] one of {TimeMath.units}.
      def initialize(name)
        @name = name
      end

      attr_reader :name

      # Rounds `tm` down to nearest unit (this means, `TimeMath.day.floor(tm)`
      # will return beginning of `tm`-s day, and so on).
      #
      # @param tm [Time,DateTime] time value to floor.
      # @return [Time,DateTime] floored time value; class and timezone info
      #   of origin would be preserved.
      def floor(tm, span = 1)
        int_floor = advance(floor_1(tm), (tm.send(name) / span.to_f).floor * span - tm.send(name))
        float_fix(tm, int_floor, span % 1)
      end

      # Rounds `tm` up to nearest unit (this means, `TimeMath.day.ceil(tm)`
      # will return beginning of day next after `tm`, and so on).
      #
      # @param tm [Time,DateTime] time value to ceil.
      # @return [Time,DateTime] ceiled time value; class and timezone info
      #   of origin would be preserved.
      def ceil(tm, span = 1)
        f = floor(tm, span)

        f == tm ? f : advance(f, span)
      end

      # Rounds `tm` up or down to nearest unit (this means, `TimeMath.day.round(tm)`
      # will return beginning of `tm` day if `tm` is before noon, and
      # day next after `tm` if it is after, and so on).
      #
      # @param tm [Time,DateTime] time value to round.
      # @return [Time,DateTime] rounded time value; class and timezone info
      #   of origin would be preserved.
      def round(tm, span = 1)
        f, c = floor(tm, span), ceil(tm, span)

        (tm - f).abs < (tm - c).abs ? f : c
      end

      # Like {#floor}, but always return value lower than `tm` (e.g. if
      # `tm` is exactly midnight, then `TimeMath.day.prev(tm)` will return
      # _previous midnight_).
      #
      # @param tm [Time,DateTime] time value to calculate prev on.
      # @return [Time,DateTime] prev time value; class and timezone info
      #   of origin would be preserved.
      def prev(tm)
        f = floor(tm)
        f == tm ? decrease(f) : f
      end

      # Like {#ceil}, but always return value greater than `tm` (e.g. if
      # `tm` is exactly midnight, then `TimeMath.day.next(tm)` will return
      # _next midnight_).
      #
      # @param tm [Time,DateTime] time value to calculate next on.
      # @return [Time,DateTime] next time value; class and timezone info
      #   of origin would be preserved.
      def next(tm)
        c = ceil(tm)
        c == tm ? advance(c) : c
      end

      # Checks if `tm` is exactly rounded to unit.
      #
      # @param tm [Time,DateTime] time value to check.
      # @return [Boolean] whether `tm` is exactly round to unit.
      def round?(tm)
        floor(tm) == tm
      end

      # Advances `tm` by given amount of unit.
      #
      # @param tm [Time,DateTime] time value to advance;
      # @param amount [Integer] how many units forward to go.
      #
      # @return [Time,DateTime] advanced time value; class and timezone info
      #   of origin would be preserved.
      def advance(tm, amount = 1)
        return decrease(tm, -amount) if amount < 0
        _advance(tm, amount)
      end

      # Decreases `tm` by given amount of unit.
      #
      # @param tm [Time,DateTime] time value to decrease;
      # @param amount [Integer] how many units forward to go.
      #
      # @return [Time,DateTime] decrease time value; class and timezone info
      #   of origin would be preserved.
      def decrease(tm, amount = 1)
        return advance(tm, -amount) if amount < 0
        _decrease(tm, amount)
      end

      # Creates range from `tm` to `tm` increased by amount of units.
      #
      # ```ruby
      # tm = Time.parse('2016-05-28 16:30')
      # TimeMath.day.range(tm, 5)
      # # => 2016-05-28 16:30:00 +0300...2016-06-02 16:30:00 +0300
      # ```
      #
      # @param tm [Time,DateTime] time value to create range from;
      # @param amount [Integer] how many units should be between range
      #   start and end.
      #
      # @return [Range]
      def range(tm, amount = 1)
        (tm...advance(tm, amount))
      end

      # Creates range from `tm` decreased by amount of units to `tm`.
      #
      # ```ruby
      # tm = Time.parse('2016-05-28 16:30')
      # TimeMath.day.range_back(tm, 5)
      # # => 2016-05-23 16:30:00 +0300...2016-05-28 16:30:00 +0300
      # ```
      #
      # @param tm [Time,DateTime] time value to create range from;
      # @param amount [Integer] how many units should be between range
      #   start and end.
      #
      # @return [Range]
      def range_back(tm, amount = 1)
        (decrease(tm, amount)...tm)
      end

      # Measures distance between `from` and `to` in units of this class.
      #
      # @param from [Time,DateTime] start of period;
      # @param to [Time,DateTime] end of period.
      #
      # @return [Integer] how many full units are inside the period.
      # :nocov:
      def measure(from, to) # rubocop:disable Lint/UnusedMethodArgument
        raise NotImplementedError,
              '#measure should be implemented in subclasses'
      end
      # :nocov:

      # Like {#measure} but also returns "remainder": the time where
      # it would be **exactly** returned amount of units between `from`
      # and `to`:
      #
      # ```ruby
      # TimeMath.day.measure(Time.parse('2016-05-01 16:20'), Time.parse('2016-05-28 15:00'))
      # # => 26
      # TimeMath.day.measure_rem(Time.parse('2016-05-01 16:20'), Time.parse('2016-05-28 15:00'))
      # # => [26, 2016-05-27 16:20:00 +0300]
      # ```
      #
      # @param from [Time,DateTime] start of period;
      # @param to [Time,DateTime] end of period.
      #
      # @return [Array<Integer, Time or DateTime>] how many full units
      #   are inside the period; exact value of `from` + full units.
      def measure_rem(from, to)
        m = measure(from, to)
        [m, advance(from, m)]
      end

      # Creates {Span} instance representing amount of units.
      #
      # Use it like this:
      #
      # ```ruby
      # span = TimeMath.day.span(5) # => #<TimeMath::Span(day): +5>
      # # now you can save this variable or path it to the methods...
      # # and then:
      # span.before(Time.parse('2016-05-01')) # => 2016-04-26 00:00:00 +0300
      # span.after(Time.parse('2016-05-01')) # => 2016-05-06 00:00:00 +0300
      # ```
      #
      # @param amount [Integer]
      # @return [Span]
      def span(amount = 1)
        TimeMath::Span.new(name, amount)
      end

      # Creates {Sequence} instance for producing all time units between
      # from and too. See {Sequence} class documentation for available
      # options and functionality.
      #
      # @param from [Time,DateTime] start of sequence;
      # @param to [Time,DateTime] upper limit of sequence;
      # @param options [Hash]
      # @option options [Boolean] :expand round sequence ends on creation
      #   (from is floored and to is ceiled);
      # @option options [Boolean] :floor sequence will be rounding'ing all
      #   the intermediate values.
      #
      # @return [Sequence]
      def sequence(range, options = {})
        TimeMath::Sequence.new(name, range, options)
      end

      def resample(array_or_hash, symbol = nil, &block)
        Resampler.call(name, array_or_hash, symbol, &block)
      end

      def inspect
        "#<#{self.class}>"
      end

      protected

      # all except :week
      NATURAL_UNITS = [:year, :month, :day, :hour, :min, :sec].freeze
      EMPTY_VALUES = [nil, 1, 1, 0, 0, 0].freeze

      def index
        NATURAL_UNITS.index(name) or
          raise NotImplementedError, "Can not be used for #{name}"
      end

      def generate(tm, replacements = {})
        hash_to_tm(tm, tm_to_hash(tm).merge(replacements))
      end

      def tm_to_hash(tm)
        Hash[*NATURAL_UNITS.flat_map { |s| [s, tm.send(s)] }]
      end

      def hash_to_tm(origin, hash)
        components = NATURAL_UNITS.map { |s| hash[s] || 0 }
        new_from_components(origin, *components)
      end

      def new_from_components(origin, *components)
        components = EMPTY_VALUES.zip(components).map { |d, c| c || d }
        case origin
        when Time
          Time.mktime(*components.reverse, nil, nil, nil, origin.zone)
        when DateTime
          DateTime.new(*components, origin.zone)
        when Date
          Date.new(*components.first(3))
        else
          raise ArgumentError, "Expected Time, Date or DateTime, got #{origin.class}"
        end
      end

      def to_components(tm)
        case tm
        when Time, DateTime
          [tm.year, tm.month, tm.day, tm.hour, tm.min, tm.sec]
        when Date
          [tm.year, tm.month, tm.day]
        else
          raise ArgumentError, "Expected Time, Date or DateTime, got #{tm.class}"
        end
      end

      def floor_1(tm)
        components = to_components(tm).first(index + 1)
        new_from_components(tm, *components)
      end

      def float_fix(tm, floored, float_span_part)
        if float_span_part.zero?
          floored
        else
          float_floored = advance(floored, float_span_part)
          float_floored > tm ? floored : float_floored
        end
      end

      include TimeMath # now we can use something like #day inside other units
    end
  end
end
