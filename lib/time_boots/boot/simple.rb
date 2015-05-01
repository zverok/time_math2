# encoding: utf-8
module TimeBoots
  class SimpleBoot < Boot
    def to_seconds(sz = 1)
      sz * MULTIPLIERS[step_idx..-1].inject(:*)
    end

    def measure(from, to)
      ((to - from) / to_seconds).to_i
    end

    protected

    def _advance(tm, steps)
      tm + to_seconds(steps)
    end

    def _decrease(tm, steps)
      tm - to_seconds(steps)
    end

    MULTIPLIERS = [12, 30, 24, 60, 60, 1]
  end

  class SecBoot < SimpleBoot
    def initialize
      super(:sec)
    end
  end

  class MinBoot < SimpleBoot
    def initialize
      super(:min)
    end
  end

  class HourBoot < SimpleBoot
    def initialize
      super(:hour)
    end
  end
end
