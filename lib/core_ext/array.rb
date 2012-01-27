module CoreExt
  module HashBy
    def hash_by(&block)
      Hash[*map { |e| [yield(e), e] }.flatten]
    end

    Array.send(:include, self)
  end
end
