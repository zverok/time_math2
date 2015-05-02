# encoding: utf-8
module TimeBoots
  class DayBoot < SimpleBoot
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

    def fix_dst(res, src)
      if res.dst? && !src.dst?
        hour.decrease(res)
      elsif !res.dst? && src.dst?
        hour.advance(res)
      else
        res
      end
    end
  end
end
