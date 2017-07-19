require 'adt/nilable'
require 'adt/types/boolean'
require 'adt/matcher'
require 'adt/non_exhaustive_match_error'
require 'adt/functions'

module ADT
  class Struct
    class << self
      attr_reader :attributes, :tag, :adt_options

      # @param adt [Module] the ADT constructor module
      # @param name [Symbol] the name of the constructor represented by the
      #   struct being created
      # @param attrs [Hash[Symbol => Class]] definition of attributes and their
      #   types. values of this hash are generally classes, but can actually be
      #   anything that "type-checks" a value using the case equality operator
      #   `===` (for example, classes defined in ADT::Types module)
      # @param opts [Hash] options
      # @option opts [Boolean] :freeze When true, all object attributes will be
      #   frozen. Note that the struct itself is always frozen regardless
      # @return [Class]
      def create_sum(adt, name, attrs, opts = {}, &block)
        Class.new(self) do
          instance_variable_set :@attributes, attrs
          instance_variable_set :@tag, name
          instance_variable_set :@adt, adt
          instance_variable_set :@adt_options, with_default_opts(opts)
          attrs.keys.each do |attr_name|
            attr_reader attr_name
          end

          include PatternMatching

          define_functions_from(&block)
        end
      end

      def create_record(name, attrs, opts = {}, &block)
        Class.new(self) do
          instance_variable_set :@attributes, attrs
          instance_variable_set :@tag, name
          instance_variable_set :@adt_options, with_default_opts(opts)

          attrs.keys.each { |a| attr_reader a }

          define_functions_from(&block)
        end
      end

      def name
        tag || super
      end

      alias_method :to_s, :name
      alias_method :inspect, :name


      def freeze?
        adt_options[:freeze]
      end

      def attribute_names
        attributes.keys
      end

      def from_hash(attrs)
        new(attrs)
      end

      private

      def define_functions_from(&block)
        functions = ADT::Functions.new(&block)
        functions.public_methods(false).each do |function_name|
          define_method(function_name) do |*args, &b|
            functions.__send__(function_name, self, *args, &b)
          end
        end
      end

      def with_default_opts(opts)
        { freeze: true }.merge(opts)
      end
    end

    def initialize(attr_values = {})
      self.class.attributes.each do |attr_name, attr_class|
        val = attr_values[attr_name]
        if type_check?(attr_class, val)
          instance_variable_set(
            :"@#{attr_name}",
            self.class.freeze? ? val.freeze : val
          )
        else
          fail(
            TypeError,
            "#{attr_name} should have type `#{attr_class.name}`, but it has " \
            "type `#{val.class.name}`"
          )
        end
      end
      freeze
    end

    def ==(other)
      return false unless other.class == self.class

      self.class.attributes.keys.all? do |attr|
        public_send(attr) == other.public_send(attr)
      end
    end

    def eql?(other)
      self == other
    end

    def hash
      to_h.hash
    end

    def to_h
      self.class.attribute_names.reduce({}) do |h, attr|
        h.merge!(attr => __send__(attr))
      end
    end

    def with(**attrs)
      self.class.new(to_h.merge!(attrs))
    end

    def over(attr)
      unless self.class.attributes.include?(attr)
        fail ArgumentError, "no attribute #{attr}"
      end
      with(attr => yield(__send__(attr)))
    end

    def inspect
      format(
        '%s%s',
        self.class.tag,
        inspect_attrs
      )
    end
    alias_method :to_s, :inspect

    private

    def inspect_attrs
      if self.class.attribute_names.empty?
        ''
      else
        attrs_str =
          self.class.attribute_names.reduce([]) do |ary, attr|
            ary << format('%s: %s', attr.to_s, __send__(attr).inspect)
          end.join(', ')
        '(' + attrs_str + ')'
      end
    end

    def type_check?(declared_type, value)
      if declared_type == :self
        value
      else
        declared_type === value
      end
    end

    module PatternMatching
      def self.included(base)
        base.extend ClassMethods
      end

      def constructor
        self.class.constructor
      end
      alias_method :__constructor__, :constructor

      def match(&block)
        self.class.match(self, &block)
      end

      # Allows you to match for side-effects. Doesn't require an exhaustive
      # match and always returns nil
      def match_effect(&block)
        self.class.match_effect(self, exhaustive: false, &block)
      end

      # Like `match_effect` but requires exhaustive match
      def match_effect!(&block)
        self.class.match_effect(self, exhaustive: true, &block)
      end

      def to_h
        super.merge!(__constructor__: __constructor__)
      end

      def inspect
        adt = self.class.adt
        adt.name ? format('%s.%s', adt.name, super) : super
      end

      module ClassMethods
        def adt
          @adt
        end

        def constructor
          self.tag
        end

        def match(value)
          matcher = ADT::Matcher.new(adt)
          yield matcher
          unless matcher.exhaustive?
            fail NonExhaustiveMatchError,
                 "unhandled constructors: #{matcher.unhandled_constructors.map(&:inspect).join(', ')}"
          end
          matcher[value.class.constructor].call(value)
        end

        def match_effect(value, exhaustive: false)
          matcher = ADT::Matcher.new(adt)
          yield matcher
          if exhaustive && !matcher.exhaustive?
            fail NonExhaustiveMatchError,
                 "unhandled constructors: #{matcher.unhandled_constructors.map(&:inspect).join(', ')}"
          end
          effect = matcher[value.class.constructor]
          effect.call(value) if effect
          nil
        end
      end
    end
  end
end
