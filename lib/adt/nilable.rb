require 'adt/types/nilable'

module ADT
  Nilable = ADT::Types::Nilable
  # # Wraps another type for use in the ADT system, allowing the value to be an
  # # instance of the wrapped type, or nil
  # class Nilable
  #   def self.[](type)
  #     new(type)
  #   end

  #   attr_reader :type

  #   def initialize(type)
  #     @type = type
  #   end

  #   def ===(other)
  #     other.nil? || type === other
  #   end

  #   def name
  #     format 'ADT::Nilable[%s]', type.name
  #   end
  # end
end
