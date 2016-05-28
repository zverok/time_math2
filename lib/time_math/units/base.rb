module TimeMath
  module Units
    class Base
      def initialize(name)
        @name = name
      end

      attr_reader :name

      def floor(tm)
        components = [tm.year,
                      tm.month,
                      tm.day,
                      tm.hour,
                      tm.min,
                      tm.sec].first(index + 1)

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

      def prev(tm)
        f = floor(tm)
        f == tm ? decrease(f) : f
      end

      def next(tm)
        c = ceil(tm)
        c == tm ? advance(c) : c
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
        raise NotImplementedError,
              '#measure should be implemented in subclasses'
      end

      def measure_rem(from, to)
        m = measure(from, to)
        [m, advance(from, m)]
      end

      def span(steps)
        TimeMath::Span.new(name, steps)
      end

      def sequence(from, to, options = {})
        TimeMath::Sequence.new(name, from, to, options)
      end

      def inspect
        "#<#{self.class}>"
      end

      protected

      # all except :week
      NATURAL_UNITS = [:year, :month, :day, :hour, :min, :sec].freeze
      EMPTY_VALUES = [nil, 1, 1, 0, 0, 0].freeze

      def index
        NATURAL_UNITS.index(name) or
          raise NotImplementedError, "Can not be used for #{name}"
      end

      def generate(tm, replacements = {})
        hash_to_tm(tm, tm_to_hash(tm).merge(replacements))
      end

      def tm_to_hash(tm)
        Hash[*NATURAL_UNITS.flat_map { |s| [s, tm.send(s)] }]
      end

      def hash_to_tm(origin, hash)
        components = NATURAL_UNITS.map { |s| hash[s] || 0 }
        new_from_components(origin, *components)
      end

      def new_from_components(origin, *components)
        components = EMPTY_VALUES.zip(components).map { |d, c| c || d }
        case origin
        when Time
          Time.mktime(*components.reverse, nil, nil, nil, origin.zone)
        when DateTime
          DateTime.new(*components, origin.zone)
        else
          raise ArgumentError, "Expected Time or DateTime, got #{origin.class}"
        end
      end

      include TimeMath # now we can use something like #day inside other units
    end
  end
end
