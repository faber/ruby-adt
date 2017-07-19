require 'adt/builder'
require 'adt/struct'
require 'adt/type'

# Algebraic Data Types
#
# Use +ADT.create+ to define a new ADT. This returns a module on which
# constructors have been defined as module methods. The constructors themselves
# return instances of subclasses of ADT::Struct
#
# @example
#   MaybeInt = ADT.create do |builder|
#     builder.data :Just, value: Integer
#     builder.data :Nothing
#   end
#   MaybeInt.Just(5).value == 5
#   MaybeInt.Nothing.constructor == :Nothing
#   MaybeInt.Just(1).constructor == :Just
#
#   just42 = MaybeInt.Just(42)
#   result = just42.match do |m|
#     m.on(:Just) { just42.value + 1 }
#     m.on(:Nothing) { 0 }
#   end
#   result == 43
#
#   User = ADT.create do |b|
#     b.data :Admin, email: String
#     b.data :Anon, name: ADT::Nilable[String]
#   end
#
#   User.Admin(email: nil) # this fails with TypeError
#   User.Admin(email: 'a@b.c').email == 'a@b.c'
#   User.Anon.name == nil # fine, since we've declared it nilable
#
module ADT
  class << self
    def sum(name = nil, freeze: true)
      builder = ADT::Builder.new
      yield builder
      ADT::Type.new(builder, name, freeze: freeze)
    end

    # Backwards-compat
    alias_method :create, :sum

    def record(name=nil, attrs={}, opts={}, &block)
      ADT::Struct.create_record(name, attrs, opts, &block)
    end

    def match(value, &block)
      value.class.match(value, &block)
    end
  end
end
