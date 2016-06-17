# encoding: utf-8
module TimeMath
  module Units
    # @private
    class Month < Base
      def initialize
        super(:month)
      end

      def measure(from, to)
        ydiff = to.year - from.year
        mdiff = to.month - from.month

        to.day >= from.day ? (ydiff * 12 + mdiff) : (ydiff * 12 + mdiff - 1)
      end

      protected

      def _succ(tm)
        return generate(tm, year: tm.year + 1, month: 1) if tm.month == 12

        t = generate(tm, month: tm.month + 1)
        fix_month(t, t.month + 1)
      end

      def _prev(tm)
        return generate(tm, year: tm.year - 1, month: 12) if tm.month == 1

        t = generate(tm, month: tm.month - 1)
        fix_month(t, t.month - 1)
      end

      def _advance(tm, steps)
        steps.times.inject(tm) { |t| _succ(t) }
      end

      def _decrease(tm, steps)
        steps.times.inject(tm) { |t| _prev(t) }
      end

      # fix for too far advance/insufficient decrease:
      #  Time.new(2013,2,31) #=> 2013-03-02 00:00:00 +0200
      def fix_month(t, expected)
        t.month == expected ? day.decrease(t, t.day) : t
      end
    end
  end
end
