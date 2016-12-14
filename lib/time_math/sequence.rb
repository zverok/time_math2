module TimeMath
  # Sequence represents a sequential units of time between two points.
  # It has several options and convenience methods for creating arrays of
  # data.
  #
  # Basic usage example:
  #
  # ```ruby
  # from = Time.parse('2016-05-01 13:30')
  # to = Time.parse('2016-05-04 18:20')
  # seq = TimeMath.day.sequence(from...to)
  # # => #<TimeMath::Sequence(2016-05-01 13:30:00 +0300...2016-05-04 18:20:00 +0300)>
  # ```
  #
  # Now, you can use it:
  #
  # ```ruby
  # seq.to_a
  # # => [2016-05-01 13:30:00 +0300, 2016-05-02 13:30:00 +0300, 2016-05-03 13:30:00 +0300, 2016-05-04 13:30:00 +0300]
  # ```
  # -- it's an "each day start between from and to". As you can see,
  # the period start is the same as in `from`.
  #
  # You can expand from and to to nearest round unit by {#expand} method
  # or `:expand` option:
  #
  # ```ruby
  # seq.expand.to_a
  # # => [2016-05-01 00:00:00 +0300, 2016-05-02 00:00:00 +0300, 2016-05-03 00:00:00 +0300, 2016-05-04 00:00:00 +0300]
  # # or:
  # seq = TimeMath.day.sequence(from...to, expand: true)
  # # => #<TimeMath::Sequence(2016-05-01 00:00:00 +0300...2016-05-05 00:00:00 +0300)>
  # seq.to_a
  # # => [2016-05-01 00:00:00 +0300, 2016-05-02 00:00:00 +0300, 2016-05-03 00:00:00 +0300, 2016-05-04 00:00:00 +0300]
  # # ^ note that `to` is excluded.
  # # You can include it by creating sequence from including-end range:
  # seq = TimeMath.day.sequence(from..to, expand: true)
  # # => #<TimeMath::Sequence(:day, 2016-05-01 00:00:00 +0300..2016-05-05 00:00:00 +0300)>
  # seq.to_a
  # # => [2016-05-01 00:00:00 +0300, 2016-05-02 00:00:00 +0300, 2016-05-03 00:00:00 +0300, 2016-05-04 00:00:00 +0300, 2016-05-05 00:00:00 +0300]
  # ```
  #
  # Besides each period beginning, you can also request pairs of begin/end
  # of a period, either as an array of arrays, or array of ranges:
  #
  # ```ruby
  # seq = TimeMath.day.sequence(from...to)
  # seq.pairs
  # # => [[2016-05-01 13:30:00 +0300, 2016-05-02 13:30:00 +0300], [2016-05-02 13:30:00 +0300, 2016-05-03 13:30:00 +0300], [2016-05-03 13:30:00 +0300, 2016-05-04 13:30:00 +0300], [2016-05-04 13:30:00 +0300, 2016-05-04 18:20:00 +0300]]
  # seq.ranges
  # # => [2016-05-01 13:30:00 +0300...2016-05-02 13:30:00 +0300, 2016-05-02 13:30:00 +0300...2016-05-03 13:30:00 +0300, 2016-05-03 13:30:00 +0300...2016-05-04 13:30:00 +0300, 2016-05-04 13:30:00 +0300...2016-05-04 18:20:00 +0300]
  # ```
  #
  # It is pretty convenient for filtering data from databases or APIs,
  # TimeMath creates list of filtering ranges in a blink.
  #
  # Sequence also supports any item-updating operations in the same fashion
  # {Op} does:
  #
  # ```ruby
  # seq = TimeMath.day.sequence(from...to, expand: true).advance(:hour, 5).decrease(:min, 20)
  # # => #<TimeMath::Sequence(:day, 2016-05-01 00:00:00 +0300...2016-05-05 00:00:00 +0300).advance(:hour, 5).decrease(:min, 20)>
  # seq.to_a
  # # => [2016-05-01 04:40:00 +0300, 2016-05-02 04:40:00 +0300, 2016-05-03 04:40:00 +0300, 2016-05-04 04:40:00 +0300]
  # ```
  #
  class Sequence
    # Creates a sequence. Typically, it is easier to to it with {Units::Base#sequence},
    # like this:
    #
    # ```ruby
    # TimeMath.day.sequence(from...to)
    # ```
    #
    # @param unit [Symbol] one of {TimeMath.units};
    # @param range [Range] range of time-y values (Time, Date, DateTime);
    #   note that range with inclusive and exclusive and will produce
    #   different sequences.
    # @param options [Hash]
    # @option options [Boolean] :expand round sequence ends on creation
    #   (`from` is floored and `to` is ceiled);
    #
    def initialize(unit, range, options = {})
      @unit = Units.get(unit)
      @from, @to, @exclude_end = process_range(range)
      @options = options.dup

      expand! if options[:expand]
      @op = Op.new
    end

    # @private
    def initialize_copy(other)
      @unit = other.unit
      @from, @to, @exclude_end = other.from, other.to, other.exclude_end?
      @op = other.op.dup
    end

    attr_reader :from, :to, :unit, :op

    # Compares two sequences, considering their start, end, unit and
    # operations.
    #
    # @param other [Sequence]
    # @return [Boolean]
    def ==(other) # rubocop:disable Metrics/AbcSize
      self.class == other.class && unit == other.unit &&
        from == other.from && to == other.to &&
        exclude_end? == other.exclude_end? &&
        op == other.op
    end

    # Whether sequence was created from exclude-end range (and, therefore,
    # will exclude `to` when converted to array).
    def exclude_end?
      @exclude_end
    end

    # Expand sequence ends to nearest round unit.
    #
    # @return [self]
    def expand!
      @from = unit.floor(from)
      @to = unit.ceil(to)

      self
    end

    # Creates new sequence with ends rounded to nearest unit.
    #
    # @return [Sequence]
    def expand
      dup.expand!
    end

    # @method floor!(unit, span = 1)
    #   Adds {Units::Base#floor} to list of operations to apply to sequence items.
    #
    #   @param unit [Symbol] One of {TimeMath.units}
    #   @param span [Numeric] how many units to floor to.
    #   @return [self]
    #
    # @method floor(unit, span = 1)
    #   Non-destructive version of {#floor!}.
    #   @param unit [Symbol] One of {TimeMath.units}
    #   @param span [Numeric] how many units to floor to.
    #   @return [Sequence]
    #
    # @method ceil!(unit, span = 1)
    #   Adds {Units::Base#ceil} to list of operations to apply to sequence items.
    #   @param unit [Symbol] One of {TimeMath.units}
    #   @param span [Numeric] how many units to ceil to.
    #   @return [self]
    #
    # @method ceil(unit, span = 1)
    #   Non-destructive version of {#ceil!}.
    #   @param unit [Symbol] One of {TimeMath.units}
    #   @param span [Numeric] how many units to ceil to.
    #   @return [Sequence]
    #
    # @method round!(unit, span = 1)
    #   Adds {Units::Base#round} to list of operations to apply to sequence items.
    #   @param unit [Symbol] One of {TimeMath.units}
    #   @param span [Numeric] how many units to round to.
    #   @return [self]
    #
    # @method round(unit, span = 1)
    #   Non-destructive version of {#round!}.
    #   @param unit [Symbol] One of {TimeMath.units}
    #   @param span [Numeric] how many units to round to.
    #   @return [Sequence]
    #
    # @method next!(unit, span = 1)
    #   Adds {Units::Base#next} to list of operations to apply to sequence items.
    #   @param unit [Symbol] One of {TimeMath.units}
    #   @param span [Numeric] how many units to ceil to.
    #   @return [self]
    #
    # @method next(unit, span = 1)
    #   Non-destructive version of {#next!}.
    #   @param unit [Symbol] One of {TimeMath.units}
    #   @param span [Numeric] how many units to ceil to.
    #   @return [Sequence]
    #
    # @method prev!(unit, span = 1)
    #   Adds {Units::Base#prev} to list of operations to apply to sequence items.
    #   @param unit [Symbol] One of {TimeMath.units}
    #   @param span [Numeric] how many units to floor to.
    #   @return [self]
    #
    # @method prev(unit, span = 1)
    #   Non-destructive version of {#prev!}.
    #   @param unit [Symbol] One of {TimeMath.units}
    #   @param span [Numeric] how many units to floor to.
    #   @return [Sequence]
    #
    # @method advance!(unit, amount = 1)
    #   Adds {Units::Base#advance} to list of operations to apply to sequence items.
    #   @param unit [Symbol] One of {TimeMath.units}
    #   @param amount [Numeric] how many units to advance.
    #   @return [self]
    #
    # @method advance(unit, amount = 1)
    #   Non-destructive version of {#advance!}.
    #   @param unit [Symbol] One of {TimeMath.units}
    #   @param amount [Numeric] how many units to advance.
    #   @return [Sequence]
    #
    # @method decrease!(unit, amount = 1)
    #   Adds {Units::Base#decrease} to list of operations to apply to sequence items.
    #   @param unit [Symbol] One of {TimeMath.units}
    #   @param amount [Numeric] how many units to decrease.
    #   @return [self]
    #
    # @method decrease(unit, amount = 1)
    #   Non-destructive version of {#decrease!}.
    #   @param unit [Symbol] One of {TimeMath.units}
    #   @param amount [Numeric] how many units to decrease.
    #   @return [Sequence]
    #

    Op::OPERATIONS.each do |operation|
      define_method "#{operation}!" do |*arg|
        @op.send("#{operation}!", *arg)
        self
      end

      define_method operation do |*arg|
        dup.send("#{operation}!", *arg)
      end
    end

   # Enumerates time unit between `from` and `to`. They will have same granularity as from
   # (e.g. if `unit` is day and from is 2016-05-01 13:30, each of return values will be next
   # day at 13:30), unless sequence is not set to floor values.
   #
   # @return [Enumerator<Time, or Date, or DateTime>]
    def each
      return to_enum(:each) unless block_given?

      iter = from
      while iter < to
        yield(op.call(iter))

        iter = unit.advance(iter)
      end
      yield(op.call(to)) unless exclude_end?
    end

    include Enumerable

    # Creates an array of pairs (time unit start, time unit end) between
    # from and to.
    #
    # @return [Array<Array>]
    def pairs
      seq = to_a
      seq.zip(seq[1..-1] + [to])
    end

    # Creates an array of Ranges (time unit start...time unit end) between
    # from and to.
    #
    # @return [Array<Range>]
    def ranges
      pairs.map { |b, e| (b...e) }
    end

    def inspect
      ops = op.inspect_operations
      ops = '.' + ops unless ops.empty?
      "#<#{self.class}(#{unit.name.inspect}, #{from}#{exclude_end? ? '...' : '..'}#{to})#{ops}>"
    end

    private

    def process_range(range)
      range.is_a?(Range) && Util.timey?(range.begin) && Util.timey?(range.end) or
        raise ArgumentError, "Range of time-y values expected, #{range} got"

      [range.begin, range.end, range.exclude_end?]
    end
  end
end
