module ADT
  module Types
    # Represents an array where all elements are the provided element type.
    # Ex: ADT::Types::Array[String] is an array of strings
    module Array
      def self.[](element_type)
        ArrayType.new(element_type)
      end

      # Internal type to represent the array type. Do not use this directly.
      class ArrayType
        def initialize(element_type)
          @element_type = element_type
        end

        def ===(other)
          other.is_a?(::Array) && other.all? { |el| element_type === el }
        end

        def name
          format 'Array[%s]', element_type.name
        end

        private

        attr_reader :element_type
      end
    end
  end
end
