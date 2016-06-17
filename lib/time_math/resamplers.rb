module TimeMath
  # @private
  class Resampler
    class << self
      def call(name, array_or_hash, symbol = nil, &block)
        if array_or_hash.is_a?(Array) && array_or_hash.all?(&method(:time?))
          ArrayResampler.new(name, array_or_hash).call
        elsif array_or_hash.is_a?(Hash) && array_or_hash.keys.all?(&method(:time?))
          HashResampler.new(name, array_or_hash).call(symbol, &block)
        else
          raise ArgumentError, "Array of timestamps or hash with timestamp keys, #{array_or_hash} got"
        end
      end

      private

      def time?(val)
        [Time, DateTime, Date].any? { |cls| val.is_a?(cls) }
      end
    end

    def initialize(unit)
      @unit = Units.get(unit)
    end

    private

    def sequence
      @sequence ||= @unit.sequence(from, to, expand: true)
    end

    def from
      timestamps.min
    end

    def to
      @unit.next(timestamps.max)
    end
  end

  # @private
  class ArrayResampler < Resampler
    def initialize(unit, array)
      super(unit)
      @array = array
    end

    def call
      sequence.to_a
    end

    private

    def timestamps
      @array
    end
  end

  class HashResampler < Resampler
    def initialize(unit, hash)
      super(unit)
      @hash = hash
    end

    def call(symbol = nil, &block)
      block = symbol.to_proc if symbol && !block

      sequence.ranges.map do |r|
        values = @hash.select { |k, _| r.cover?(k) }.map(&:last)
        values = block.call(values) if block # rubocop:disable Performance/RedundantBlockCall
        [r.begin, values]
      end.to_h
    end

    private

    def timestamps
      @hash.keys
    end
  end
end
