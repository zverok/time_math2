# encoding: utf-8
module TimeBoots
  class Boot
    class << self
      def steps
        BOOTS.keys
      end
      
      def get(step)
        BOOTS[step] or
          fail(ArgumentError, "Unsupported step: #{step}")
      end
    end
    
    def initialize(step)
      @step = step
    end

    attr_reader :step

    def floor(tm)
      components = [tm.year,
                    tm.month,
                    tm.day,
                    tm.hour,
                    tm.min,
                    tm.sec].first(step_idx + 1)
        
      Time.new(*components)
    end

    def ceil(tm)
      f = floor(tm)

      f == tm ? f : advance(f)
    end

    def advance(tm, steps = 1)
      return decrease(tm, -steps) if steps < 0
      
      if respond_to?(:_advance)
        _advance(tm, steps)
      elsif respond_to?(:succ)
        steps.times.inject(tm){|t| succ(t)}
      else
        fail(NotImplementedError, 'No advancing method')
      end
    end

    def decrease(tm, steps = 1)
      return advance(tm, -steps) if steps < 0
      
      if respond_to?(:_decrease)
        _decrease(tm, steps)
      elsif respond_to?(:prev)
        steps.times.inject(tm){|t| prev(t)}
      else
        fail(NotImplementedError, 'No descreasing method')
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

    def generate(tm, replacements = {})
      hash_to_tm(tm_to_hash(tm).merge(replacements))
    end

    def tm_to_hash(tm)
      Hash[*NATURAL_STEPS.map{|s| [s, tm.send(s)]}.flatten(1)]
    end

    def hash_to_tm(hash)
      components = NATURAL_STEPS.map{|s| hash[s] || 0}
      Time.new(*components)
    end
  end

  class SimpleBoot < Boot
    def span(sz = 1)
      sz * MULTIPLIERS[step_idx..-1].inject(:*)
    end

    def measure(from, to)
      ((to - from) / span).to_i
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

    def hour
      Boot.hour
    end
  end

  class WeekBoot < SimpleBoot
    def initialize
      super(:week)
    end

    def floor(tm)
      f = day.floor(tm)
      extra_days = tm.wday == 0 ? 6 : tm.wday - 1
      day.decrease(f, extra_days)
    end

    def span(sz)
      day.span(sz * 7)
    end

    protected

    def _advance(tm, steps)
      day.advance(tm, steps * 7)
    end

    def _decrease(tm, steps)
      day.decrease(tm, steps * 7)
    end
    
    def day
      Boot.day
    end
  end

  class MonthBoot < Boot
    def initialize
      super(:month)
    end

    def measure(from, to)
      ydiff = to.year - from.year
      mdiff = to.month - from.month

      to.day >= from.day ? (ydiff * 12 + mdiff) : (ydiff * 12 + mdiff - 1)
    end

    protected

    def succ(tm)
      return generate(tm, year: tm.year + 1, month: 1) if tm.month == 12

      t = generate(tm, month: tm.month + 1)
      fix_month(t, t.month + 1)
    end

    def prev(tm)
      return generate(tm, year: tm.year - 1, month: 12) if tm.month == 1

      t = generate(tm, month: tm.month - 1)
      fix_month(t, t.month - 1)
    end

    # fix for too far advance/insufficient decrease:
    #  Time.new(2013,2,31) #=> 2013-03-02 00:00:00 +0200
    def fix_month(t, expected)
      t.month == expected ? day.decrease(t, t.day) : t
    end

    def day
      Boot.day
    end
  end

  class YearBoot < Boot
    def initialize
      super(:year)
    end

    def measure(from, to)
      if generate(from, year: to.year) < to
        to.year - from.year
      else
        to.year - from.year - 1
      end
    end

    protected
    
    def _advance(tm, steps)
      generate(tm, year: tm.year + steps)
    end

    def _decrease(tm, steps)
      generate(tm, year: tm.year - steps)
    end
  end

  class Boot
    BOOTS = {
      sec: SecBoot.new,
      min: MinBoot.new,
      hour: HourBoot.new,
      day: DayBoot.new,
      week: WeekBoot.new,
      month: MonthBoot.new,
      year: YearBoot.new
    }

    class << self
      BOOTS.keys.each do |step|
        define_method(step){BOOTS[step]}
      end
    end
  end
end
