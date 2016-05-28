module TimeMath
  class Sequence
    def initialize(unit, from, to, options = {})
      @unit = Units.get(unit)
      @from, @to = from, to
      @options = options.dup

      expand! if options[:expand]
    end

    attr_reader :from, :to

    def expand!
      @from = unit.floor(from)
      @to = unit.ceil(to)

      self
    end

    def expand
      dup.tap(&:expand!)
    end

    def to_a(floor = false)
      seq = []

      iter = from
      while iter < to
        seq << iter

        iter = cond_floor(unit.advance(iter), floor)
      end

      seq
    end

    def pairs(floor = false)
      seq = to_a(floor)
      seq.zip(seq[1..-1] + [to])
    end

    def ranges(floor = false)
      pairs(floor).map { |b, e| (b...e) }
    end

    def inspect
      "#<#{self.class}(#{from} - #{to})>"
    end

    private

    def cond_floor(tm, should_floor)
      should_floor ? unit.floor(tm) : tm
    end

    attr_reader :unit
  end
end
