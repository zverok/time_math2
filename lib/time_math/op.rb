module TimeMath
  # `Op` is value object, incapsulating several operations performed on
  # time unit. The names of operations are the same the single unit can
  # perform, first parameter is always a unit.
  #
  # Ops can be created by `TimeMath::Op.new` or with pretty shortcut
  # `TimeMath()`.
  #
  # Available usages:
  #
  # ```ruby
  # # 1. chain operations:
  # # without Op: 10:25 at first day of next week:
  # TimeMath.min.advance(TimeMath.hour.advance(TimeMath.week.ceil(tm), 10), 25)
  # # FOOOOOO
  # # ...but with Op:
  # TimeMath(tm).ceil(:week).advance(:hour, 10).advance(:min, 25).call
  #
  # # 2. chain operations on multiple objects:
  # TimeMath(tm1, tm2, tm3).ceil(:week).advance(:hour, 10).advance(:min, 25).call
  # # or
  # TimeMath([array_of_times]).ceil(:week).advance(:hour, 10).advance(:min, 25).call
  #
  # # 3. preparing operation to be used on any objects:
  # op = TimeMath().ceil(:week).advance(:hour, 10).advance(:min, 25)
  # op.call(tm)
  # op.call(tm1, tm2, tm3)
  # op.call(array_of_times)
  # # or even block-ish behavior:
  # [tm1, tm2, tm3].map(&op)
  # ```
  #
  # Note that Op also plays well with {Sequence} (see its docs for more).
  class Op
    # @private
    OPERATIONS = %i[floor ceil round next prev advance decrease].freeze

    attr_reader :operations, :arguments

    # Creates Op. Could (and recommended be also by its alias -- just
    # `TimeMath(*arguments)`.
    #
    # @param arguments one, or several, or an array of time-y values
    #   (Time, Date, DateTime).
    def initialize(*arguments)
      @arguments = arguments
      @operations = []
    end

    # @private
    def initialize_copy(other)
      @arguments = other.arguments.dup
      @operations = other.operations.dup
    end

    # @method floor!(unit, span = 1)
    #   Adds {Units::Base#floor} to list of operations.
    #
    #   @param unit [Symbol] One of {TimeMath.units}
    #   @param span [Numeric] how many units to floor to.
    #   @return [self]
    #
    # @method floor(unit, span = 1)
    #   Non-destructive version of {#floor!}.
    #   @param unit [Symbol] One of {TimeMath.units}
    #   @param span [Numeric] how many units to floor to.
    #   @return [Op]
    #
    # @method ceil!(unit, span = 1)
    #   Adds {Units::Base#ceil} to list of operations.
    #   @param unit [Symbol] One of {TimeMath.units}
    #   @param span [Numeric] how many units to ceil to.
    #   @return [self]
    #
    # @method ceil(unit, span = 1)
    #   Non-destructive version of {#ceil!}.
    #   @param unit [Symbol] One of {TimeMath.units}
    #   @param span [Numeric] how many units to ceil to.
    #   @return [Op]
    #
    # @method round!(unit, span = 1)
    #   Adds {Units::Base#round} to list of operations.
    #   @param unit [Symbol] One of {TimeMath.units}
    #   @param span [Numeric] how many units to round to.
    #   @return [self]
    #
    # @method round(unit, span = 1)
    #   Non-destructive version of {#round!}.
    #   @param unit [Symbol] One of {TimeMath.units}
    #   @param span [Numeric] how many units to round to.
    #   @return [Op]
    #
    # @method next!(unit, span = 1)
    #   Adds {Units::Base#next} to list of operations.
    #   @param unit [Symbol] One of {TimeMath.units}
    #   @param span [Numeric] how many units to ceil to.
    #   @return [self]
    #
    # @method next(unit, span = 1)
    #   Non-destructive version of {#next!}.
    #   @param unit [Symbol] One of {TimeMath.units}
    #   @param span [Numeric] how many units to ceil to.
    #   @return [Op]
    #
    # @method prev!(unit, span = 1)
    #   Adds {Units::Base#prev} to list of operations.
    #   @param unit [Symbol] One of {TimeMath.units}
    #   @param span [Numeric] how many units to floor to.
    #   @return [self]
    #
    # @method prev(unit, span = 1)
    #   Non-destructive version of {#prev!}.
    #   @param unit [Symbol] One of {TimeMath.units}
    #   @param span [Numeric] how many units to floor to.
    #   @return [Op]
    #
    # @method advance!(unit, amount = 1)
    #   Adds {Units::Base#advance} to list of operations.
    #   @param unit [Symbol] One of {TimeMath.units}
    #   @param amount [Numeric] how many units to advance.
    #   @return [self]
    #
    # @method advance(unit, amount = 1)
    #   Non-destructive version of {#advance!}.
    #   @param unit [Symbol] One of {TimeMath.units}
    #   @param amount [Numeric] how many units to advance.
    #   @return [Op]
    #
    # @method decrease!(unit, amount = 1)
    #   Adds {Units::Base#decrease} to list of operations.
    #   @param unit [Symbol] One of {TimeMath.units}
    #   @param amount [Numeric] how many units to decrease.
    #   @return [self]
    #
    # @method decrease(unit, amount = 1)
    #   Non-destructive version of {#decrease!}.
    #   @param unit [Symbol] One of {TimeMath.units}
    #   @param amount [Numeric] how many units to decrease.
    #   @return [Op]
    #

    OPERATIONS.each do |op|
      define_method "#{op}!" do |unit, *args|
        Units.names.include?(unit) or raise(ArgumentError, "Unknown unit #{unit}")
        @operations << [op, unit, args]
        self
      end

      define_method op do |unit, *args|
        dup.send("#{op}!", unit, *args)
      end
    end

    def inspect
      "#<#{self.class}#{inspect_args}" + inspect_operations + '>'
    end

    # @private
    def inspect_operations
      operations.map { |op, unit, args|
        "#{op}(#{[unit, *args].map(&:inspect).join(', ')})"
      }.join('.')
    end

    def ==(other)
      self.class == other.class && operations == other.operations &&
        arguments == other.arguments
    end

    # Performs op. If an Op was created with arguments, just performs all
    # operations on them and returns the result. If it was created without
    # arguments, performs all operations on arguments provided to `call`.
    #
    # @param tms one, or several, or an array of time-y values; should not
    #   be passed if Op was created with arguments.
    # @return [Time,Date,DateTime,Array] one, or an array of processed arguments
    def call(*tms)
      unless @arguments.empty?
        tms.empty? or raise(ArgumentError, 'Op arguments is already set, use call()')
        tms = @arguments
      end
      res = [*tms].flatten.map(&method(:perform))
      tms.count == 1 && Util.timey?(tms.first) ? res.first : res
    end

    # Allows to use Op as a block:
    #
    # ```ruby
    # timestamps.map(&TimeMath().ceil(:week).advance(:day, 1))
    # ```
    # @return [Proc]
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
