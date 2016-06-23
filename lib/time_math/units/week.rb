module TimeMath
  module Units
    # @private
    class Week < Simple
      def initialize
        super(:week)
      end

      def floor(tm, span = 1)
        span == 1 or
          raise NotImplementedError, 'For now, week only can floor to one'

        f = TimeMath.day.floor(tm)
        extra_days = tm.wday == 0 ? 6 : tm.wday - 1
        TimeMath.day.decrease(f, extra_days)
      end

      def to_seconds(sz = 1)
        TimeMath.day.to_seconds(sz * 7)
      end

      protected

      def _advance(tm, steps)
        TimeMath.day.advance(tm, steps * 7)
      end

      def _decrease(tm, steps)
        TimeMath.day.decrease(tm, steps * 7)
      end
    end
  end
end
