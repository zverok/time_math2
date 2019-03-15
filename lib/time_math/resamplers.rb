module TimeMath
  # @private
  class Resampler
    class << self
      def call(unit, array_or_hash, symbol = nil, &block)
        resampler =
          ArrayResampler.try(unit, array_or_hash) ||
          HashResampler.try(unit, array_or_hash) or
          raise ArgumentError, "Expected array of timestamps or hash with timestamp keys, #{array_or_hash} got"

        resampler.call(symbol, &block)
      end
    end

    def initialize(unit)
      @unit = Units.get(unit)
    end

    def call
      raise NotImplementedError
    end

    private

    def sequence
      @sequence ||= @unit.sequence(timestamps.min..timestamps.max)
    end
  end

  # @private
  class ArrayResampler < Resampler
    def self.try(unit, array)
      return nil unless array.is_a?(Array) && array.all?(&Util.method(:timey?))

      new(unit, array)
    end

    def initialize(unit, array)
      super(unit)
      @array = array
    end

    def call(*)
      sequence.to_a
    end

    private

    def timestamps
      @array
    end
  end

  # @private
  class HashResampler < Resampler
    def self.try(unit, hash)
      return nil unless hash.is_a?(Hash) && hash.keys.all?(&Util.method(:timey?))

      new(unit, hash)
    end

    def initialize(unit, hash)
      super(unit)
      @hash = hash
    end

    def call(symbol = nil, &block)
      block = symbol.to_proc if symbol && !block

      sequence.ranges.map do |r|
        values = @hash.select { |k, _| r.cover?(k) }.map(&:last)
        values = block.call(values) if block
        [r.begin, values]
      end.to_h
    end

    private

    def timestamps
      @hash.keys
    end
  end
end
