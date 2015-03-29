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
      beginnings = options.delete(:beginnings) ||
        options.delete(:beginning) ||
        options.delete(:begs) ||
        options.delete(:beg)

      options.empty? or fail("Unknown options: #{options}")
      
      seq = []

      iter = from
      while iter < to
        seq << iter

        iter = if beginnings
          boot.floor(boot.advance(iter))
        else
          boot.advance(iter)
        end
      end
      
      seq
    end

    private
    
    attr_reader :boot
  end
end
