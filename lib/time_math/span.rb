module TimeMath
  class Span
    def initialize(unit_name, amount)
      @unit_name, @amount = unit_name, amount
      @unit = Units.get(unit_name)
    end

    attr_reader :unit_name, :amount

    def before(tm = Time.now)
      @unit.decrease(tm, amount)
    end

    def after(tm = Time.now)
      @unit.advance(tm, amount)
    end

    alias ago before
    alias from after

    def ==(other)
      self.class == other.class &&
        unit_name == other.unit_name && amount == other.amount
    end

    def inspect
      '#<%s(%s): %+i>' % [self.class, unit_name, amount]
    end
  end
end
