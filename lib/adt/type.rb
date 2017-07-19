require 'adt/struct'

module ADT
  # Represents an ADT data type. Holds all its constructors and exposes them via
  # singleton methods. Should not be used directly, but rather thru ADT.create,
  # which returns an instance of this class
  class Type
    attr_reader :struct_classes, :constructors, :name

    # @param struct_classes [Hash[Symbol => Class]]
    # @param builder [ADT::Builder]
    # @param name [String, nil]
    # @param freeze [Boolean] when true, all values will be frozen. In general
    #   you should leave this true
    def initialize(builder, name = nil, freeze: true)
      @struct_classes =
        builder.defs.inject({}) do |hash, (ctor_name, attr_defs)|
          hash.merge!(
            ctor_name => ADT::Struct.create_sum(
              self,
              ctor_name,
              attr_defs,
              { freeze: freeze },
              &builder.functions_block
            )
          )
        end
      @constructors = struct_classes.keys
      @name = name || 'ADT::Type'

      define_constructor_methods(builder)
    end

    def from_hash(hash)
      struct_classes[hash[:__constructor__].to_sym].from_hash(hash)
    end

    def ===(other)
      struct_classes.values.any? { |klass| other.is_a?(klass) }
    end

    def inspect
      name
    end

    def to_s
      inspect
    end

    private

    def define_constructor_methods(builder)
      builder.defs.each do |constructor_name, attr_hash|
        define_singleton_method(constructor_name) do |*args, **kwargs|
          construct_value(constructor_name, attr_hash, args, kwargs)
        end
      end
    end

    def construct_value(constructor_name, defined_attrs, args, kwargs)
      unless args.empty? || kwargs.empty?
        fail ArgumentError, 'must construct ADT values with EITHER positional '\
                            'or keyword arguments, not both'
      end
      struct_class = struct_classes[constructor_name]

      attrs =
        if !args.empty?
          attrs_from_positional_args(defined_attrs, args)
        else
          kwargs
        end
      struct_class.new(attrs)
    end

    def attrs_from_positional_args(defined_attrs, args)
      defined_attrs.keys.each_with_index.reduce({}) do |h, (attr_name, index)|
        h.merge! attr_name => args[index]
      end
    end
  end
end
