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

  test 'run callbacks when created' do
    order = orders(:one)
    item = order.items.build(sku: 'SKU111', quantity: 2)
    item.should_calculate_price = true

    assert item.save
    refute_equal 0.0, item.price
  end

  test 'query all items with native adapter' do
    matching_item_from_order_1 = orders(:one).items.find_by(quantity: 1)
    matching_item_from_order_2 = orders(:two).items.find_by(quantity: 1)
    non_matching_item_from_order_1 = orders(:two).items.find_by(quantity: 2)
    non_matching_item_from_order_2 = orders(:two).items.find_by(quantity: 4)

    assert Item.any?
    assert_equal 5, Item.count

    [
      Item.where(quantity: 1).order(created_at: :desc),
      Item.order(created_at: :desc).where(quantity: 1)
    ].each do |collection|
      refute_empty collection
      assert_includes collection, matching_item_from_order_1
      assert_includes collection, matching_item_from_order_2
      refute_includes collection, non_matching_item_from_order_1
      refute_includes collection, non_matching_item_from_order_2
    end
  end
end
