module TimeMath
  module Units
    # @private
    class Simple < Base
      def to_seconds(sz = 1)
        sz * MULTIPLIERS[index..-1].inject(:*)
      end

      protected

      def _measure(from, to)
        ((to.to_time - from.to_time) / to_seconds).to_i
      end

      def _advance(tm, steps)
        _shift(tm, to_seconds(steps))
      end

      def _decrease(tm, steps)
        _shift(tm, -to_seconds(steps))
      end

      def _shift(tm, seconds)
        case tm
        when Time
          tm + seconds
        when Date
          tm + Rational(seconds, 86_400)
        else
          raise ArgumentError, "Expected Time or DateTime, got #{tm.class}"
        end
      end

      MULTIPLIERS = [12, 30, 24, 60, 60, 1].freeze
    end

    # @private
    class Sec < Simple
      def initialize
        super(:sec)
      end
    end

    # @private
    class Min < Simple
      def initialize
        super(:min)
      end
    end

    # @private
    class Hour < Simple
      def initialize
        super(:hour)
      end
    end
  end
end
