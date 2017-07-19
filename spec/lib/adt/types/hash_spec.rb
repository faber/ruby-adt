require 'spec_helper'
require 'adt/types/hash'

describe ADT::Types::Hash do
  subject(:type) { described_class[Symbol, Integer] }

  it 'matches hashes of the right shape' do
    expect(type === { a: 1 }).to be(true)
  end

  it 'matches empty hashes' do
    expect(type === {}).to be(true)
  end

  it 'does not match non-hashes' do
    expect(type === 'foo').to be(false)
    expect(type === 3.8).to be(false)
    expect(type === :bar).to be(false)
  end

  it 'does not match hashes of a different shape' do
    expect(type === { a: '7' }).to be(false)
    expect(type === { 'a' => 1 }).to be(false)
    expect(type === { 'foo' => 8.2 }).to be(false)
  end
end
