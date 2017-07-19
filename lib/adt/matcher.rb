require 'adt/invalid_constructor'

module ADT
  class Matcher
    # @param adt [Moudle] the adt constructor module returned by ADT.create
    def initialize(adt)
      @adt = adt
      @procs = {}
    end

    def [](type_name)
      @procs[type_name]
    end

    def on(*type_names, &block)
      if type_names.empty?
        fail ArgumentError, 'must supply constructor to `Matcher#on`'
      end

      type_names.each do |type_name|
        unless @adt.constructors.include?(type_name)
          fail InvalidConstructor, "invalid constructor `#{type_name.inspect}`"
        end
      end

      type_names.each { |type_name| @procs[type_name] = block }

      nil
    end

    def otherwise(&block)
      unhandled_constructors.each do |type_name|
        on(type_name, &block)
      end
      nil
    end

    # @return [Boolean]
    def exhaustive?
      unhandled_constructors.empty?
    end

    def unhandled_constructors
      @adt.constructors - @procs.keys
    end
  end
end
