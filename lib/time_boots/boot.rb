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

    def span(sz = 1)
      sz * MULTIPLIERS[step_idx..-1].inject(:*)
    end

    def advance(tm, steps = 1)
      tm + span(steps)
    end

    def decrease(tm, steps = 1)
      tm - span(steps)
    end

    def beginning?(tm)
      floor(tm) == tm
    end

    private

    NATURAL_STEPS = [:year, :month, :day, :hour, :min, :sec]
    MULTIPLIERS = [12, 30, 24, 60, 60, 1]

    def step_idx
      NATURAL_STEPS.index(step) or
        fail(NotImplementedError, "Can not be used for step #{step}")
    end

  end

  class SecBoot < Boot
    def initialize
      super(:sec)
    end
  end

  class MinBoot < Boot
    def initialize
      super(:min)
    end
  end

  class HourBoot < Boot
    def initialize
      super(:hour)
    end
  end

  class DayBoot < Boot
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

    def advance(tm, steps = 1)
      steps.times.inject(tm){|t| succ(t)}
    end

    def decrease(tm, steps = 1)
      steps.times.inject(tm){|t| prev(t)}
    end

    private

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

    def advance(tm, steps = 1)
      Time.new(tm.year+steps, tm.month, tm.day, tm.hour, tm.min, tm.sec) 
    end

    def decrease(tm, steps = 1)
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
