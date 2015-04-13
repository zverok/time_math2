# encoding: utf-8
module TimeBoots
  class Span
    def initialize(step, amount)
      @step, @amount = step, amount
      @boot = Boot.get(step)
    end

    def before(tm = Time.now)
      @boot.decrease(tm, amount)
    end

    def after(tm = Time.now)
      @boot.advance(tm, amount)
    end

    alias_method :ago, :before 
    alias_method :from, :after

    attr_reader :step, :amount
  end
end
