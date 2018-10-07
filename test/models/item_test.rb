require 'test_helper'

class Hashable
  delegate :to_h, to: :@attributes

  def initialize(params = {})
    @attributes = params
  end
end

class Unhashable
  def initialize(params = {})
    @attributes = params
  end
end

class ItemTest < ActiveSupport::TestCase
  setup do
    @item = Item.new(
      sku: 'SKU123',
      quantity: 1,
      price: 9.99,
      customizations: { engraving: 'LT' }
    )
  end

  test 'preserve types' do
    assert_equal 'SKU123', @item.sku
    assert_equal 1, @item.quantity
    assert_equal 9.99, @item.price
    assert_equal 'LT', @item.customizations[:engraving]
  end

  test 'convert types' do
    @item.quantity = '3'
    @item.price = 9
    @item.customizations = Hashable.new(foo: 'bar')
    @item.discounts = nil

    assert_equal 3, @item.quantity
    assert_equal 9.0, @item.price
    assert_kind_of Hash, @item.customizations
    assert_equal 'bar', @item.customizations[:foo]
  end

  test 'attributes are constrained to fields' do
    assert_raises(NoMethodError) do
      @item.foo = 'bar'
    end

    assert_raises(ActiveRecord::Embedded::Field::NotDefinedError) do
      @item[:foo] = 'bar'
    end
  end
end
