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
    # See also {TimeMath::Op} for performing multiple operations in
    # concise & DRY manner, like this:
    #
    # ```ruby
    # TimeMath().advance(:day, 5).floor(:hour).advance(:min, 20).call(tm)
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
      # An optional second argument allows you to floor to arbitrary
      # number of units, like to "each 3-hour" mark:
      #
      # ```ruby
      # TimeMath.hour.floor(Time.parse('14:00'), 3)
      # # => 2016-06-23 12:00:00 +0300
      #
      # # works well with float/rational spans
      # TimeMath.hour.floor(Time.parse('14:15'), 1/2r)
      # # => 2016-06-23 14:00:00 +0300
      # TimeMath.hour.floor(Time.parse('14:45'), 1/2r)
      # # => 2016-06-23 14:30:00 +0300
      # ```
      #
      # @param tm [Time,Date,DateTime] time value to floor.
      # @param span [Numeric] how many units to floor to. For units
      #   less than week supports float/rational values.
      # @return [Time,Date,DateTime] floored time value; class and timezone
      #   info of origin would be preserved.
      def floor(tm, span = 1)
        int_floor = advance(floor_1(tm), (tm.send(name) / span.to_f).floor * span - tm.send(name))
        float_fix(tm, int_floor, span % 1)
      end

      # Rounds `tm` up to nearest unit (this means, `TimeMath.day.ceil(tm)`
      # will return beginning of day next after `tm`, and so on).
      # An optional second argument allows to ceil to arbitrary
      # amount of units (see {#floor} for more detailed explanation).
      #
      # @param tm [Time,Date,DateTime] time value to ceil.
      # @param span [Numeric] how many units to ceil to. For units
      #   less than week supports float/rational values.
      # @return [Time,Date,DateTime] ceiled time value; class and timezone info
      #   of origin would be preserved.
      def ceil(tm, span = 1)
        f = floor(tm, span)

        f == tm ? f : advance(f, span)
      end

      # Rounds `tm` up or down to nearest unit (this means, `TimeMath.day.round(tm)`
      # will return beginning of `tm` day if `tm` is before noon, and
      # day next after `tm` if it is after, and so on).
      # An optional second argument allows to round to arbitrary
      # amount of units (see {#floor} for more detailed explanation).
      #
      # @param tm [Time,Date,DateTime] time value to round.
      # @param span [Numeric] how many units to round to. For units
      #   less than week supports float/rational values.
      # @return [Time,Date,DateTime] rounded time value; class and timezone info
      #   of origin would be preserved.
      def round(tm, span = 1)
        f, c = floor(tm, span), ceil(tm, span)

        (tm - f).abs < (tm - c).abs ? f : c
      end

      # Like {#floor}, but always return value lower than `tm` (e.g. if
      # `tm` is exactly midnight, then `TimeMath.day.prev(tm)` will return
      # _previous midnight_).
      # An optional second argument allows to floor to arbitrary
      # amount of units (see {#floor} for more detailed explanation).
      #
      # @param tm [Time,Date,DateTime] time value to calculate prev on.
      # @param span [Numeric] how many units to floor to. For units
      #   less than week supports float/rational values.
      # @return [Time,Date,DateTime] prev time value; class and timezone info
      #   of origin would be preserved.
      def prev(tm, span = 1)
        f = floor(tm, span)
        f == tm ? decrease(f, span) : f
      end

      # Like {#ceil}, but always return value greater than `tm` (e.g. if
      # `tm` is exactly midnight, then `TimeMath.day.next(tm)` will return
      # _next midnight_).
      # An optional second argument allows to ceil to arbitrary
      # amount of units (see {#floor} for more detailed explanation).
      #
      # @param tm [Time,Date,DateTime] time value to calculate next on.
      # @param span [Numeric] how many units to ceil to. For units
      #   less than week supports float/rational values.
      # @return [Time,Date,DateTime] next time value; class and timezone info
      #   of origin would be preserved.
      def next(tm, span = 1)
        c = ceil(tm, span)
        c == tm ? advance(c, span) : c
      end

      # Checks if `tm` is exactly rounded to unit.
      #
      # @param tm [Time,Date,DateTime] time value to check.
      # @param span [Numeric] how many units to check round at. For units
      #   less than week supports float/rational values.
      # @return [Boolean] whether `tm` is exactly round to unit.
      def round?(tm, span = 1)
        floor(tm, span) == tm
      end

      # Advances `tm` by given amount of unit.
      #
      # @param tm [Time,Date,DateTime] time value to advance;
      # @param amount [Numeric] how many units forward to go. For units
      #   less than week supports float/rational values.
      #
      # @return [Time,Date,DateTime] advanced time value; class and timezone info
      #   of origin would be preserved.
      def advance(tm, amount = 1)
        return decrease(tm, -amount) if amount < 0
        _advance(tm, amount)
      end

      # Decreases `tm` by given amount of unit.
      #
      # @param tm [Time,Date,DateTime] time value to decrease;
      # @param amount [Integer] how many units forward to go. For units
      #   less than week supports float/rational values.
      #
      # @return [Time,Date,DateTime] decrease time value; class and timezone info
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
      # @param tm [Time,Date,DateTime] time value to create range from;
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
      # @param tm [Time,Date,DateTime] time value to create range from;
      # @param amount [Integer] how many units should be between range
      #   start and end.
      #
      # @return [Range]
      def range_back(tm, amount = 1)
        (decrease(tm, amount)...tm)
      end

      # Measures distance between `from` and `to` in units of this class.
      #
      # @param from [Time,Date,DateTime] start of period;
      # @param to [Time,Date,DateTime] end of period.
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
      # @param from [Time,Date,DateTime] start of period;
      # @param to [Time,Date,DateTime] end of period.
      #
      # @return [Array<Integer, Time or DateTime>] how many full units
      #   are inside the period; exact value of `from` + full units.
      def measure_rem(from, to)
        m = measure(from, to)
        [m, advance(from, m)]
      end

      # Creates {Sequence} instance for producing all time units between
      # from and too. See {Sequence} class documentation for available
      # options and functionality.
      #
      # @param from [Time,Date,DateTime] start of sequence;
      # @param to [Time,Date,DateTime] upper limit of sequence;
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

      # Converts input timestamps list to regular list of timestamps
      # over current unit.
      #
      # Like this:
      #
      # ```ruby
      # times = [Time.parse('2016-05-01'), Time.parse('2016-05-03'), Time.parse('2016-05-08')]
      # TimeMath.day.resample(times)
      # # =>  => [2016-05-01 00:00:00 +0300, 2016-05-02 00:00:00 +0300, 2016-05-03 00:00:00 +0300, 2016-05-04 00:00:00 +0300, 2016-05-05 00:00:00 +0300, 2016-05-06 00:00:00 +0300, 2016-05-07 00:00:00 +0300, 2016-05-08 00:00:00 +0300]
      # ```
      #
      # The best way about resampling it also works for hashes with time
      # keys. Like this:
      #
      # ```ruby
      # h = {Date.parse('Wed, 01 Jun 2016')=>1, Date.parse('Tue, 07 Jun 2016')=>3, Date.parse('Thu, 09 Jun 2016')=>1}
      # # => {#<Date: 2016-06-01>=>1, #<Date: 2016-06-07>=>3, #<Date: 2016-06-09>=>1}
      #
      # pp TimeMath.day.resample(h)
      # # {#<Date: 2016-06-01>=>[1],
      # #  #<Date: 2016-06-02>=>[],
      # #  #<Date: 2016-06-03>=>[],
      # #  #<Date: 2016-06-04>=>[],
      # #  #<Date: 2016-06-05>=>[],
      # #  #<Date: 2016-06-06>=>[],
      # #  #<Date: 2016-06-07>=>[3],
      # #  #<Date: 2016-06-08>=>[],
      # #  #<Date: 2016-06-09>=>[1]}
      #
      # # The default resample just groups all related values in arrays
      # # You can pass block or symbol, to have the values you need:
      # pp TimeMath.day.resample(h,&:first)
      # # {#<Date: 2016-06-01>=>1,
      # #  #<Date: 2016-06-02>=>nil,
      # #  #<Date: 2016-06-03>=>nil,
      # #  #<Date: 2016-06-04>=>nil,
      # #  #<Date: 2016-06-05>=>nil,
      # #  #<Date: 2016-06-06>=>nil,
      # #  #<Date: 2016-06-07>=>3,
      # #  #<Date: 2016-06-08>=>nil,
      # #  #<Date: 2016-06-09>=>1}
      # ```
      #
      # @param array_or_hash array of time-y values (Time/Date/DateTime)
      #   or hash with time-y keys.
      # @param symbol in case of first param being a hash -- method to
      #   call on key arrays while grouping.
      # @param block in  case of first param being a hash -- block to
      #   call on key arrays while grouping.
      #
      # @return array or hash spread regular by unit; if first param was
      #   hash, keys corresponding to each period are grouped into arrays;
      #   this array could be further processed with block/symbol provided.
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
          Time.new(*components, origin.utc_offset)
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
    end
  end
end
