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

      new_from_components(tm, *components)
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
      _advance(tm, steps)
    end

    def decrease(tm, steps = 1)
      return advance(tm, -steps) if steps < 0
      _decrease(tm, steps)
    end

    def range(tm, steps = 1)
      (tm...advance(tm, steps))
    end

    def range_back(tm, steps = 1)
      (decrease(tm, steps)...tm)
    end

    def measure(_from, _to)
      raise NotImplementedError, '#measure should be implemented in subclasses'
    end

    def measure_rem(from, to)
      m = measure(from, to)
      [m, advance(from, m)]
    end

    def jump(steps)
      Jump.new(step, steps)
    end

    def lace(from, to, options = {})
      Lace.new(step, from, to, options)
    end

    protected

    NATURAL_STEPS = [:year, :month, :day, :hour, :min, :sec].freeze
    DEFAULT_STEP_VALUES = [nil, 1, 1, 0, 0, 0].freeze

    def step_idx
      NATURAL_STEPS.index(step) or
        raise NotImplementedError, "Can not be used for step #{step}"
    end

    def generate(tm, replacements = {})
      hash_to_tm(tm, tm_to_hash(tm).merge(replacements))
    end

    def tm_to_hash(tm)
      Hash[*NATURAL_STEPS.flat_map { |s| [s, tm.send(s)] }]
    end

    def hash_to_tm(origin, hash)
      components = NATURAL_STEPS.map { |s| hash[s] || 0 }
      new_from_components(origin, *components)
    end

    def new_from_components(origin, *components)
      components = DEFAULT_STEP_VALUES.zip(components).map { |d, c| c || d }
      case origin
      when Time
        Time.mktime(*components.reverse, nil, nil, nil, origin.zone)
      when DateTime
        DateTime.new(*components, origin.zone)
      else
        raise ArgumentError, "Expected Time or DateTime, got #{origin.class}"
      end
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
    }.freeze

    class << self
      def steps
        BOOTS.keys
      end

      def get(step)
        BOOTS[step] or
          raise ArgumentError, "Unsupported step: #{step}"
      end
    end
  end
end
