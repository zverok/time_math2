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
  # seq = TimeMath.day.sequence(from, to)
  # # => #<TimeMath::Sequence(2016-05-01 13:30:00 +0300 - 2016-05-04 18:20:00 +0300)>
  # ```
  #
  # Now, you can use it:
  # ```ruby
  # seq.to_a
  # # => [2016-05-01 13:30:00 +0300, 2016-05-02 13:30:00 +0300, 2016-05-03 13:30:00 +0300, 2016-05-04 13:30:00 +0300]
  # ```
  # -- it's an "each day start between from and to". As you can see,
  # the period start is the same as in `from`. You can request to floor
  # them to beginning of day with {#floor} method or `:floor` option:
  #
  # ```ruby
  # seq.floor.to_a
  # # => [2016-05-01 13:30:00 +0300, 2016-05-02 00:00:00 +0300, 2016-05-03 00:00:00 +0300, 2016-05-04 00:00:00 +0300]
  # # or:
  # seq = TimeMath.day.sequence(from, to, floor: true)
  # seq.to_a
  # ```
  # -- it floors all day starts except of `from`, which is preserved.
  #
  # You can expand from and to to nearest round unit by {#expand} method
  # or `:expand` option:
  #
  # ```ruby
  # seq.expand.to_a
  # # => [2016-05-01 00:00:00 +0300, 2016-05-02 00:00:00 +0300, 2016-05-03 00:00:00 +0300, 2016-05-04 00:00:00 +0300]
  # # or:
  # seq = TimeMath.day.sequence(from, to, expand: true)
  # # => #<TimeMath::Sequence(2016-05-01 00:00:00 +0300 - 2016-05-05 00:00:00 +0300)>
  # seq.to_a
  # ```
  #
  # Besides each period beginning, you can also request pairs of begin/end
  # of a period, either as an array of arrays, or array of ranges:
  #
  # ```ruby
  # seq = TimeMath.day.sequence(from, to)
  # seq.pairs
  # # => [[2016-05-01 13:30:00 +0300, 2016-05-02 13:30:00 +0300], [2016-05-02 13:30:00 +0300, 2016-05-03 13:30:00 +0300], [2016-05-03 13:30:00 +0300, 2016-05-04 13:30:00 +0300], [2016-05-04 13:30:00 +0300, 2016-05-04 18:20:00 +0300]]
  # seq.ranges
  # # => [2016-05-01 13:30:00 +0300...2016-05-02 13:30:00 +0300, 2016-05-02 13:30:00 +0300...2016-05-03 13:30:00 +0300, 2016-05-03 13:30:00 +0300...2016-05-04 13:30:00 +0300, 2016-05-04 13:30:00 +0300...2016-05-04 18:20:00 +0300]
  # ```
  #
  # It is pretty convenient for filtering data from databases or APIs,
  # TimeMath creates list of filtering ranges in a blink.
  #
  class Sequence
    # Creates a sequence. Typically, it is easier to to it with {Units::Base#sequence},
    # like this:
    #
    # ```ruby
    # TimeMath.day.sequence(from, to)
    # ```
    #
    # @param unit [Symbol] one of {TimeMath.units};
    # @param from [Time,DateTime] start of sequence;
    # @param to [Time,DateTime] upper limit of sequence;
    # @param options [Hash]
    # @option options [Boolean] :expand round sequence ends on creation
    #   (from is floored and to is ceiled);
    # @option options [Boolean] :floor sequence will be rounding'ing all
    #   the intermediate values.
    #
    def initialize(unit, range, options = {})
      @unit = Units.get(unit)
      @from, @to, @exclude_end = process_range(range)
      @options = options.dup

      expand! if options[:expand]
      @floor = options[:floor]
      @op = Op.new
    end

    attr_reader :from, :to, :unit, :op

    def ==(other) # rubocop:disable Metrics/AbcSize
      self.class == other.class && unit == other.unit &&
        from == other.from && to == other.to &&
        exclude_end? == other.exclude_end?
    end

    def exclude_end?
      @exclude_end
    end

    # If `:floor` option is set for sequence.
    def floor?
      @floor
    end

    # Expand sequence ends to nearest round unit.
    #
    # @return self
    def expand!
      @from = unit.floor(from)
      @to = unit.ceil(to)

      self
    end

    # Creates new sequence with ends rounded to nearest unit.
    #
    # @return [Sequence]
    def expand
      dup.tap(&:expand!)
    end

    # Sets sequence to floor all the intermediate values.
    #
    # @return self
    def floor!
      @floor = true
    end

    # Creates new sequence with setting to floor all the intermediate
    # values.
    #
    # @return [Sequence]
    def floor
      dup.tap(&:floor!)
    end

    Op::OPERATIONS.each do |operation|
      define_method operation do |*arg|
        @op.send(operation, *arg)
        self
      end
    end

    # Creates an array of time unit starts between from and to. They will
    # have same granularity as from (e.g. if unit is day and from is
    # 2016-05-01 13:30, each of return values will be next day at 13:30),
    # unless sequence is not set to floor values.
    #
    # @return [Array<Time or DateTime>]
    def to_a
      seq = []

      iter = from
      while iter < to
        seq << iter

        iter = cond_floor(unit.advance(iter))
      end
      seq << to unless exclude_end?

      op.call(seq)
    end

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

    def cond_floor(tm)
      @floor ? unit.floor(tm) : tm
    end
  end
end
