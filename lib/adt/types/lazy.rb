module ADT
  module Types
    def self.Lazy
      LazyType.new { yield }
    end

    class LazyType
      def initialize(&block)
        fail ArgumentError, 'block required' unless block_given?
        @thunk = block
      end

      def ===(other)
        wrapped_type === other
      end

      def name
        if realized?
          wrapped_type.name
        else
          format '##unrealized lazy type##'
        end
      end

      private

      def realized?
        !@wrapped_type.nil?
      end

      def wrapped_type
        @wrapped_type ||= @thunk.call
      end
    end
  end
end
