require 'spec_helper'
require 'adt/struct'

describe ADT::Struct do
  describe 'ADT sum structs' do
    let(:struct_class) do
      described_class.create_sum(adt, :MyStruct, id: Integer, name: String)
    end

    let(:no_attrs_class) do
      described_class.create_sum(adt, :NoAttrs, {})
    end

    let(:adt) { double(name: 'FooBar') }

    describe 'constructor' do
      it 'assigns attributes by keywords' do
        obj = struct_class.new(id: 123, name: 'David')
        expect(obj.id).to eq(123)
        expect(obj.name).to eq('David')
      end

      it 'does typechecking and fails with a TypeError' do
        expect do
          struct_class.new(id: '1232', name: 'David')
        end.to raise_error(TypeError, /id should have type `Integer`/)
      end

      it 'does not accept nil by default' do
        expect do
          struct_class.new(id: 1232)
        end.to raise_error(TypeError, /name should have type `String`/)
      end

      it 'can have explicitly nilable fields' do
        struct_class = described_class.create_sum(
          adt, :Nils, a: ADT::Nilable[String]
        )
        expect(struct_class.new({}).a).to be(nil)
      end
    end

    describe 'frozen attributes' do
      it 'freezes all attributes when set to do so' do
        struct_class = described_class.create_sum(
          adt, :Foo, { a: String }, { freeze: true }
        )
        expect(struct_class.new(a: 'bar').a).to be_frozen
      end

      it 'does not freeze attributes when set not to do so' do
        struct_class = described_class.create_sum(
          adt, :Foo, { a: String }, { freeze: false }
        )
        expect(struct_class.new(a: 'bar').a).not_to be_frozen
      end
    end

    describe '#constructor' do
      it 'returns the constructor name' do
        expect(struct_class.new(id: 1, name: 'D').constructor).to eq(:MyStruct)
      end

      it 'is aliased as __constructor__ in case :constructor is an attribute' do
        sc = struct_class.create_sum(adt, :WithCtor, constructor: Symbol)
        obj = sc.new(constructor: :confusing_indeed)
        expect(obj.constructor).to eq(:confusing_indeed)
        expect(obj.__constructor__).to eq(:WithCtor)
      end
    end

    describe '#==' do
      it 'is equal if it is part of the same ADT with same ctor and attrs' do
        v1 = struct_class.new(id: 1, name: '2')
        v2 = struct_class.new(id: 1, name: '2')
        expect(v1).to eq(v2)

        expect(v1).not_to eq('wuh')
        expect(v1).not_to eq(struct_class.new(id: 2, name: '2'))
      end
    end

    describe '#to_h' do
      it 'dumps the ADT to a hash' do
        v = struct_class.new(id: 1, name: '2')
        expect(v.to_h).to eq(__constructor__: :MyStruct, id: 1, name: '2')
      end
    end

    describe '#inspect' do
      it 'sets a friendly name' do
        v = struct_class.new(id: 1, name: 'Jo')
        expect(v.inspect).to eq('FooBar.MyStruct(id: 1, name: "Jo")')
      end

      it 'leaves off parens if there are no attrs' do
        expect(no_attrs_class.new({}).inspect).to eq('FooBar.NoAttrs')
      end
    end

    describe '#with' do
      it 'creates a new value with updated attributes' do
        v1 = struct_class.new(id: 1, name: 'Tom')
        v2 = v1.with(name: 'Thom')
        expect(v1.id).to eq(1)
        expect(v1.name).to eq('Tom')
        expect(v2.id).to eq(1)
        expect(v2.name).to eq('Thom')
      end

      it 'runs the usual type checks' do
        v = struct_class.new(id: 1, name: 'Link')
        expect { v.with(name: 47.9) }.to raise_error(TypeError, /name/)
      end
    end

    describe '#over' do
      it 'applies the block to the attribute and returns a new struct' do
        v1 = struct_class.new(id: 1, name: 'Bob')
        v2 = v1.over(:id) { |i| i + 1 }
        expect(v2.id).to eq(2)
        expect(v2.name).to eq('Bob')
        expect(v1.id).to eq(1)
      end

      it 'fails with ArgumentError for unknown attributes' do
        expect do
          struct_class.new(id: 1, name: 'Jo').over(:foo) { |*| 7 }
        end.to raise_error(ArgumentError)
      end

      it 'fails with TypeError if the block returns the wrong type' do
        expect do
          struct_class.new(id: 1, name: 'Jo').over(:id, &:to_s)
        end.to raise_error(TypeError)
      end
    end

    it 'can define functions that become instance methods' do
      klass =
        described_class.create_sum(adt, :Flam, floo: String) do
          def my_method(struct)
            struct.floo.upcase
          end
        end
      expect(klass.new(floo: 'bar').my_method).to eq('BAR')
    end
  end

  describe 'ADT record structs' do
    let(:struct_class) do
      described_class.create_record('My::Struct', id: String)
    end

    it 'works like an ADT struct' do
      a = struct_class.new(id: '1')
      b = struct_class.new(id: '1')
      c = b.with(id: '7')
      expect(a.id).to eq('1')
      expect(a).to eq(b)
      expect(c.id).to eq('7')
    end

    it 'does not have a match or match_effect method' do
      a = struct_class.new(id: '5')
      expect(a).not_to respond_to(:match)
      expect(a).not_to respond_to(:match_effect)
    end

    it 'has a friendly inspect name, if provided' do
      expect(struct_class.new(id: '1').inspect).to eq('My::Struct(id: "1")')
    end

    it 'can define functions that become instance methods on the struct' do
      klass =
        described_class.create_record('Thing', a: Integer) do
          def b(thing)
            thing.a + 1
          end
        end

      expect(klass.new(a: 1).b).to eq(2)
    end
  end
end
