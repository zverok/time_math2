module TimeMath
  module Units
    # @private
    class Day < Simple
      def initialize
        super(:day)
      end

      protected

      def _advance(tm, steps)
        fix_dst(super(tm, steps), tm)
      end

      def _decrease(tm, steps)
        fix_dst(super(tm, steps), tm)
      end

      # :nocov: - somehow Travis env thinks other things about DST
      def fix_dst(res, src)
        return res unless res.is_a?(Time)

        if res.dst? && !src.dst?
          TimeMath.hour.decrease(res)
        elsif !res.dst? && src.dst?
          TimeMath.hour.advance(res)
        else
          res
        end
      end
      # :nocov:
    end
  end
end
