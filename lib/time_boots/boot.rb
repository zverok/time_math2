# encoding: utf-8
module TimeBoots
  class Boot
    def self.get(step)
      TimeBoots::STEPS.include?(step) or
        fail("Unsupported step: #{step}")

      BOOTS[step].new
    end
    
    def initialize(step)
      TimeBoots::STEPS.include?(step) or
        fail("Unsupported step: #{step}")

      @step = step
    end

    attr_reader :step

    def floor(tm)
      Time.new(*[tm.year, tm.month, tm.day, tm.hour, tm.min, tm.sec].first(step_idx+1))
    end

    def ceil(tm)
      f = floor(tm)

      f == tm ?
        f :
        advance(f)
    end

    def advance(tm, steps = 1)
      return decrease(tm, -steps) if steps < 0
      
      if respond_to?(:_advance)
        _advance(tm, steps)
      elsif respond_to?(:succ)
        steps.times.inject(tm){|t| succ(t)}
      else
        fail(NotImplementedError, "No advancing method")
      end
    end

    def decrease(tm, steps = 1)
      return advance(tm, -steps) if steps < 0
      
      if respond_to?(:_decrease)
        _decrease(tm, steps)
      elsif respond_to?(:prev)
        steps.times.inject(tm){|t| prev(t)}
      else
        fail(NotImplementedError, "No descreasing method")
      end
    end

    def beginning?(tm)
      floor(tm) == tm
    end

    protected
    
    NATURAL_STEPS = [:year, :month, :day, :hour, :min, :sec]

    def step_idx
      NATURAL_STEPS.index(step) or
        fail(NotImplementedError, "Can not be used for step #{step}")
    end
  end

  class SimpleBoot < Boot
    def span(sz = 1)
      sz * MULTIPLIERS[step_idx..-1].inject(:*)
    end

    protected

    def _advance(tm, steps)
      tm + span(steps)
    end

    def _decrease(tm, steps)
      tm - span(steps)
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

  class DayBoot < SimpleBoot
    def initialize
      super(:day)
    end
  end

  class WeekBoot < Boot
    def initialize
      super(:week)
    end

    def floor(tm)
      d = Boot.get(:day) # FIXME: ugly
      
      d.advance(d.floor(tm), -(tm.wday==0 ? 6 : tm.wday-1))
    end
  end

  class MonthBoot < Boot
    def initialize
      super(:month)
    end

    protected

    def succ(tm)
      if tm.month == 12
        Time.new(tm.year+1, 1, tm.day, tm.hour, tm.min, tm.sec) 
      else
        t = Time.new(tm.year, tm.month+1, tm.day, tm.hour, tm.min, tm.sec)

        # fix for too far advance: Time.new(2013,2,31) #=> 2013-03-02 00:00:00 +0200
        t.month == tm.month + 2 ?
          day.decrease(t, t.day.days) :
          t
      end
    end

    def prev(tm)
      if tm.month == 1
        Time.new(tm.year-1, 12, tm.day, tm.hour, tm.min, tm.sec) 
      else
        t = Time.new(tm.year, tm.month - 1, tm.day, tm.hour, tm.min, tm.sec) 

        # fix for insufficient decrease: Time.new(2013,2,31) #=> 2013-03-02 00:00:00 +0200
        t.month == tm.month ?
          day.decrease(t, t.day) :
          t
      end
    end

    def day
      Boot.get(:day)
    end
  end

  class YearBoot < Boot
    def initialize
      super(:year)
    end

    protected
    
    def _advance(tm, steps)
      Time.new(tm.year+steps, tm.month, tm.day, tm.hour, tm.min, tm.sec) 
    end

    def _decrease(tm, steps)
      Time.new(tm.year-steps, tm.month, tm.day, tm.hour, tm.min, tm.sec) 
    end
  end

  class Boot
      BOOTS = {
      sec: SecBoot,
      min: MinBoot,
      hour: HourBoot,
      day: DayBoot,
      week: WeekBoot,
      month: MonthBoot,
      year: YearBoot
    }
  end
end
