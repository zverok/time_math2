module TimeMath
  # Represents time span (amount of units), like "4 years".
  # Allows to advance or decrease Time or DateTime.
  #
  # Use it like this:
  #
  # ```ruby
  # TimeMath.year.span(4).before(Time.now)
  # ```
  #
  class Span
    attr_reader :unit, :amount

    # Creates Span instance.
    # Typically, it is easire to use {Units::Base#span} than create
    # spans directly.
    #
    # @param unit [Symbol] one of {Units.names}, unit of span;
    # @param amount [Integer] amount of units in span.
    def initialize(unit, amount)
      @unit, @amount = unit, amount
      @unit_impl = Units.get(unit)
    end

    # Decreases `tm` by `amount` of `unit`.
    #
    # @param tm [Time,DateTime] time value to decrease;
    # @return [Time,DateTime] decreased time.
    def before(tm = Time.now)
      @unit_impl.decrease(tm, amount)
    end

    # Increases `tm` by `amount` of `unit`.
    #
    # @param tm [Time,DateTime] time value to increase;
    # @return [Time,DateTime] increased time.
    def after(tm = Time.now)
      @unit_impl.advance(tm, amount)
    end

    alias ago before
    alias from after

    def ==(other)
      self.class == other.class &&
        unit == other.unit && amount == other.amount
    end

    def inspect
      '#<%s(%s): %+i>' % [self.class, unit, amount]
    end
  end
end
