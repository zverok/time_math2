# encoding: utf-8
module TimeBoots
  class Lace
    def initialize(step, from, to, options = {})
      @boot = Boot.get(step)
      @from, @to = from, to
      @options = options.dup
    end

    attr_reader :from, :to

    def expand!
      @from = @boot.floor(from)
      @to = @boot.ceil(to)
      
      self
    end

    def expand
      dup.tap(&:expand!)
    end
  end
end
