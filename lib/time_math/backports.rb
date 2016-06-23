class Array
  if RUBY_VERSION < '2.0'
    def to_h
      Hash[*self.flatten(1)]
    end
  end
end
