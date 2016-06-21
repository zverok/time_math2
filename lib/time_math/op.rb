module TimeMath
  class Op
    OPERATIONS = [:floor, :ceil, :round, :next, :prev, :advance, :decrease].freeze

    attr_reader :operations, :arguments

    def initialize(*arguments)
      @arguments = arguments
      @operations = []
    end

    OPERATIONS.each do |op|
      define_method op do |unit, *args|
        Units.names.include?(unit) or raise(ArgumentError, "Unknown unit #{unit}")
        @operations << [op, unit, args]
        self
      end
    end

    def inspect
      "#<#{self.class}#{inspect_args}" + inspect_operations + '>'
    end

    def inspect_operations
      operations.map { |op, unit, args|
        "#{op}(#{[unit, *args].map(&:inspect).join(', ')})"
      }.join('.')
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
      tm.count == 1 && Util.timey?(tm.first) ? res.first : res
    end

    def to_proc
      method(:call).to_proc
    end

    private

    def inspect_args
      return ' ' if @arguments.empty?
      '(' + [*@arguments].map(&:inspect).join(', ') + ').'
    end

    def perform(tm)
      operations.inject(tm) { |memo, (op, unit, args)|
        TimeMath::Units.get(unit).send(op, memo, *args)
      }
    end
  end
end
