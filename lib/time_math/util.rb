module TimeMath
  # @private
  module Util
    module_function

    def timey?(val)
      [Time, DateTime, Date].any? { |cls| val.is_a?(cls) }
    end
  end
end
