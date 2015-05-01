# encoding: utf-8
module TimeBoots
  class DayBoot < SimpleBoot
    def initialize
      super(:day)
    end

    protected

    def _advance(tm, steps)
      res = super(tm, steps)

      if res.dst? && !tm.dst?
        hour.decrease(res)
      elsif !res.dst? && tm.dst?
        hour.advance(res)
      else
        res
      end
    end

    def _decrease(tm, steps)
      res = super(tm, steps)

      if res.dst? && !tm.dst?
        hour.decrease(res)
      elsif !res.dst? && tm.dst?
        hour.advance(res)
      else
        res
      end
    end
  end
end
