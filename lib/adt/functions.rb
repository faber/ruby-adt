module ADT
  # Use this to create helper modules which are used in defining struct
  # functions
  class Functions
    def initialize(&block)
      extend Module.new(&block) if block_given?
    end
  end
end
