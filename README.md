# ADT

Algebraic Data Types and a flexible runtime "type system", inspired by Haskell,
in Ruby.

## Installation

## Usage

### Structs and Sum Types

ADT can be used to either define typed, immutable structs, or a Union of
multiple struct types.

Consider the following definitions:

```
Pitch = ADT.sum 'Pitch' do |b|
  b.data :A
  b.data :B
  b.data :C
  b.data :D
  b.data :E
  b.data :F
  b.data :G
end

Note = ADT.record(
  'Note',
  pitch: Pitch,
  octave: Integer
)

Chord = ADT.record(
  'Chord',
  notes: ADT::Types::Array[Note]
)

```

Pitch is essentially an "enum" type. Notes are records of a name, pitch and
octave, each of which will be type-checked at initialization. All structs are
completely immutable. You can perform a simple "record update" constructor to
create new instances from existing ones:

```
a4 = Note.new(pitch: Pitch.A, octave: 4)
b4 = a4.with(pitch: Pitch.B)
a5 = a4.with(octave: 5)
```


### Custom types

With the `Chord` record, we've used a higher order custom type,
`ADT::Types::Array`. These are easy to define, making the "runtime type system"
very expressive. A handful of utility types come with ruby-adt, defined in the
`ADT::Types` namespace.

A custom type is an object that response to `===`, which should return `true` if
the argument is of the object's type. It can optionally also respond to `name`
with a prettified representation of itself. Here are some examples:

```
# A type representing a single value

class Literal
  def self.[](value)
    new(value)
  end

  def initialize(value)
    @value = value
  end

  def ===(other)
    value == other
  end

  def name
    format 'Literal[%s]', value.inspect
  end

  private

  attr_reader :value
end

Literal['a'] === 'a'
Literal['a'] !== :a


# An array

class ArrayType
  def self.[](element_type)
    new(element_type)
  end

  def initialize(element_type)
    @element_type = element_type
  end

  def ===(value)
    value.is_a?(Array) && value.all? { |el| element_type === el }
  end

  def name
    format 'Array[%s]', element_type.name
  end

  private

  attr_reader :element_type
end

```


### Defining functions on Simple Structs

Data objects are pure data, and so have no behavior. However, in an OO language
like Ruby, it is highly convenient for data objects to have instance methods.
How do we reconcile this purity with this convenience?

ADT lets you define functions of the data, which are then made accessible on all
the data objects.

```
NameType = ADT.record('Name', first: String, last: String) do
  # @param name [NameType]
  def full_name(name)
    [name.first, name.last].join(' ')
  end

  def greeting(name, prefix)
    prefix + name.full_name
  end
end

sigrud = NameType.new(first: 'Sigrud', last: 'je Harkvaldsson')

sigrud.full_name == 'Sigrud je Harkvaldsson'
sigrud.greeing 'Mr. ' == 'Mr. Sigrud je Harkvaldsson'
```

The "instance method" `full_name` is not executed in the context of a NameType
object, but rather it is passed one as an argument, and thus is not really an
instance method but a pure function.

### Defining functions on Sum Types and Pattern Matching

Functions can also be defined on sum types but the declaration is a little bit
different:

```
Cardinality = ADT.sum do |b|
  b.data(:One)
  b.data(:Many)

  b.functions do
    def one?(c)
      c.match do |m|
        m.on(:One) { true }
        m.on(:Many) { false }
      end
    end

    def many?(c)
      c.match do |m|
        m.on(:One) { false }
        m.on(:Many) { true }
      end
    end
  end
end

```

Above is also an example of how to use pattern matching on sum types. The
matching process validates itself at runtime, raising exceptions if any cases
are either unknown or missing. An exhaustive match is always required.
