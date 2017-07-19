module ADT
  module Types
    # Represents a hash where all keys and values are of the types specified.
    # Ex: ADT::Types::Hash[Symbol, Integer] is a hash mapping symbols to
    # integers
    module Hash
      def self.[](key_type, value_type)
        HashType.new(key_type, value_type)
      end

      # Internal type to represent the hash type.  Do not use this direclty
      class HashType
        def initialize(key_type, value_type)
          @key_type = key_type
          @value_type = value_type
        end

        def ===(other)
          other.is_a?(::Hash) &&
            other.all? { |k, v| key_type === k && value_type === v }
        end

        def name
          format 'Hash[%s => %s]', key_type.name, value_type.name
        end

        private

        attr_reader :key_type, :value_type
      end
    end
  end
end
