# encoding: utf-8
module TimeBoots
  class Boot
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

    def round(tm)
      f, c = floor(tm), ceil(tm)

      (tm - f).abs < (tm - c).abs ? f : c
    end

    def round?(tm)
      floor(tm) == tm
    end

    def advance(tm, steps = 1)
      return decrease(tm, -steps) if steps < 0
      
      # gotcha: respond_to?(:protected_method) is false in Ruby > 2.0
      if methods.include?(:_advance)
        _advance(tm, steps)
      elsif methods.include?(:succ)
        steps.times.inject(tm){|t| succ(t)}
      else
        fail(NotImplementedError, 'No advancing method')
      end
    end

    def decrease(tm, steps = 1)
      return advance(tm, -steps) if steps < 0

      # gotcha: respond_to?(:protected_method) is false in Ruby > 2.0
      if methods.include?(:_decrease)
        _decrease(tm, steps)
      elsif methods.include?(:prev)
        steps.times.inject(tm){|t| prev(t)}
      else
        fail(NotImplementedError, 'No descreasing method')
      end
    end

    def range(tm, steps = 1)
      (tm...advance(tm, steps))
    end

    def range_back(tm, steps = 1)
      (decrease(tm, steps)...tm)
    end

    def measure(_from, _to)
      fail NotImplementedError, 'Should be implemented in subclasses'
    end

    def measure_rem(from, to)
      m = measure(from, to)
      [m, advance(from, m)]
    end

    def span(steps)
      Span.new(step, steps)
    end

    def lace(from, to, options = {})
      Lace.new(step, from, to, options)
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

    include TimeBoots # now we can use something like #day inside boots

    require_relative 'boot/simple'
    require_relative 'boot/day'
    require_relative 'boot/week'
    require_relative 'boot/month'
    require_relative 'boot/year'
  
    BOOTS = {
      sec: SecBoot.new, min: MinBoot.new, hour: HourBoot.new,
      day: DayBoot.new, week: WeekBoot.new, month: MonthBoot.new,
      year: YearBoot.new
    }

    class << self
      def steps
        BOOTS.keys
      end
      
      def get(step)
        BOOTS[step] or
          fail(ArgumentError, "Unsupported step: #{step}")
      end
    end
  end
end
