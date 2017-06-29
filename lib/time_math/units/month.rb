# encoding: utf-8

module TimeMath
  module Units
    # @private
    class Month < Base
      def initialize
        super(:month)
      end

      protected

      def _measure(from, to)
        ydiff = to.year - from.year
        mdiff = to.month - from.month

        to.day >= from.day ? (ydiff * 12 + mdiff) : (ydiff * 12 + mdiff - 1)
      end

      def _advance(tm, steps)
        target = tm.month + steps.to_i
        m = (target - 1) % 12 + 1
        dy = (target - 1) / 12
        Util.merge(tm, year: tm.year + dy, month: m)
      end

      def _decrease(tm, steps)
        _advance(tm, -steps)
      end
    end
  end
end
