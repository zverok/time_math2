# @private
class Array
  if RUBY_VERSION < '2.1'
    def to_h
      Hash[*flatten(1)]
    end
  end
end
