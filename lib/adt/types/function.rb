module ADT
  module Types
    module Function
      def self.[](*args)
        FunctionType.new(*args)
      end

      class FunctionType
        def initialize(*args)
          @args = args
        end

        def ===(other)
          Proc === other
        end
      end
    end
  end
end
