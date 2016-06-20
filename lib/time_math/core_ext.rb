require 'time_math'

module TimeMath
  # This module is included into `Time` and `DateTime`. It is optional
  # and only included by explicit `require "time_math/core_ext"`.
  module CoreExt
    # @!method floor_to(unit)
    #   Shortcut to {Units::Base#floor}
    # @!method ceil_to(unit)
    #   Shortcut to {Units::Base#ceil}
    # @!method round_to(unit)
    #   Shortcut to {Units::Base#round}
    # @!method next_to(unit)
    #   Shortcut to {Units::Base#next}
    # @!method prev_to(unit)
    #   Shortcut to {Units::Base#prev}
    [:floor, :ceil, :round, :next, :prev].each do |sym|
      define_method("#{sym}_to") { |unit| TimeMath[unit].send(sym, self) }
    end

    # Shortcut to {Units::Base#round?}
    def round_to?(unit)
      TimeMath[unit].round?(self)
    end

    # Shortcut to {Units::Base#advance}
    def advance_by(unit, amount = 1)
      TimeMath[unit].advance(self, amount)
    end

    # Shortcut to {Units::Base#decrease}
    def decrease_by(unit, amount = 1)
      TimeMath[unit].decrease(self, amount)
    end

    # Shortcut to {Units::Base#range}
    def range_to(unit, amount = 1)
      TimeMath[unit].range(self, amount)
    end

    # Shortcut to {Units::Base#range_back}
    def range_from(unit, amount = 1)
      TimeMath[unit].range_back(self, amount)
    end

    # Shortcut to {Units::Base#sequence}. See its docs for possible options.
    def sequence_to(unit, other, options = {})
      TimeMath[unit].sequence(self...other, options)
    end
  end

  Time.send :include, CoreExt
  DateTime.send :include, CoreExt if ::Kernel.const_defined?(:DateTime)
end
