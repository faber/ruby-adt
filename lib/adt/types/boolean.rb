module ADT
  module Types
    # Hack so that we can declare ADT attributes as boolean
    module Boolean
      def self.===(other)
        other == true || other == false
      end
    end
  end
end
