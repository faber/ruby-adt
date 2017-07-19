module ADT
  module Types
    module Union
      def self.[](*types)
        UnionType.new(types)
      end

      class UnionType
        def initialize(types)
          @types = types
        end

        def ===(other)
          types.any? { |t| t === other }
        end

        def name
          format 'Union[%s]', types.map(&:name).join(', ')
        end

        private

        attr_reader :types
      end
    end
  end
end
