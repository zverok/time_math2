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
      @from = boot.floor(from)
      @to = boot.ceil(to)
      
      self
    end

    def expand
      dup.tap(&:expand!)
    end

    def pull(options = {})
      beginnings = options.delete(:beginnings)
      
      seq = []

      iter = from
      while iter < to
        seq << iter

        iter = cond_floor(boot.advance(iter), beginnings)
      end
      
      seq
    end

    private

    def cond_floor(tm, should_floor)
      should_floor ? boot.floor(tm) : tm
    end
    
    attr_reader :boot
  end
end
