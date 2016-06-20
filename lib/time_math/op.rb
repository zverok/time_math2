module TimeMath
  class Op
    attr_reader :operations, :arguments

    def initialize(*arguments)
      @arguments = arguments
      @operations = []
    end

    [:floor, :ceil, :round, :next, :prev, :advance, :decrease].each do |meth|
      define_method meth do |unit, *args|
        Units.names.include?(unit) or raise(ArgumentError, "Unknown unit #{unit}")
        @operations << [meth, unit, args]
        self
      end
    end

    def inspect
      "#<#{self.class}#{inspect_args}" +
        operations.map { |op, unit, args|
          "#{op}(#{[unit, *args].map(&:inspect).join(', ')})"
        }.join('.') + '>'
    end

    def ==(other)
      self.class == other.class && operations == other.operations &&
        arguments == other.arguments
    end

    def call(*tm)
      unless @arguments.empty?
        tm.empty? or raise(ArgumentError, 'Op arguments is already set, use call()')
        tm = @arguments
      end
      res = [*tm].flatten.map(&method(:perform))
      tm.count == 1 && time?(tm.first) ? res.first : res
    end

    private

    def inspect_args
      return ' ' if @arguments.empty?
      '(' + [*@arguments].map(&:inspect).join(', ') + ').'
    end

    def time?(val)
      [Time, DateTime, Date].any? { |cls| val.is_a?(cls) }
    end

    def perform(tm)
      operations.inject(tm) { |memo, (op, unit, args)|
        TimeMath::Units.get(unit).send(op, memo, *args)
      }
    end
  end
end
