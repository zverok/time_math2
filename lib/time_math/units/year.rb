module TimeMath
  module Units
    # @private
    class Year < Base
      def initialize
        super(:year)
      end

      def measure(from, to)
        if Util.merge(from, year: to.year) < to
          to.year - from.year
        else
          to.year - from.year - 1
        end
      end

      protected

      def _advance(tm, steps)
        Util.merge(tm, year: tm.year + steps.to_i)
      end

      def _decrease(tm, steps)
        Util.merge(tm, year: tm.year - steps.to_i)
      end
    end
  end
end
