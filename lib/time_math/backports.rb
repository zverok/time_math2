# @private
class Array
  if RUBY_VERSION < '2.0'
    def to_h
      Hash[*flatten(1)]
    end
  end
end
