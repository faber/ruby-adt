module ADT
  module Types
    # Matches any type
    module Any
      def self.===(_other)
        true
      end

      def self.name
        'Any'
      end
    end
  end
end
