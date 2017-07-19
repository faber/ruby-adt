module ADT
  module Types
    module Literal
      def self.[](value)
        LiteralType.new(value)
      end

      class LiteralType
        def initialize(value)
          @value = value
        end

        def ===(other)
          value == other
        end

        def name
          format 'Literal[%s]', value.inspect
        end

        private

        attr_reader :value
      end
    end
  end
end
