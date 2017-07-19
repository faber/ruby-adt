module ADT
  module Types
    module Nilable
      def self.[](type)
        NilableType.new(type)
      end

      class NilableType
        attr_reader :type

        def initialize(type)
          @type = type
        end

        def ===(other)
          other.nil? || type === other
        end

        def name
          format 'ADT::Nilable[%s]', type.name
        end
      end
    end
  end
end
