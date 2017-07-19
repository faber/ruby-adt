module ADT
  class Builder
    attr_reader :defs, :functions_block

    def initialize
      @defs = {}
      @functions_block = nil
    end

    def data(name, **attr_hash)
      defs[name.to_sym] = attr_hash
    end

    def functions(&block)
      @functions_block = block
    end
  end
end
