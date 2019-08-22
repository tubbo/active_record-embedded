# frozen_string_literal: true

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
    @_original_adapter = ActiveRecord::Embedded.config.adapter
    ActiveRecord::Embedded.config.adapter = :native

    matching_item_from_order1 = orders(:one).items.find_by(quantity: 1)
    matching_item_from_order2 = orders(:two).items.find_by(quantity: 1)
    non_matching_item_from_order1 = orders(:two).items.find_by(quantity: 2)
    non_matching_item_from_order2 = orders(:two).items.find_by(quantity: 4)

    assert Item.any?
    assert_equal 5, Item.count

    [
      Item.where(quantity: 1).order(created_at: :desc),
      Item.order(created_at: :desc).where(quantity: 1)
    ].each do |collection|
      refute_empty collection
      assert_includes collection, matching_item_from_order1
      assert_includes collection, matching_item_from_order2
      refute_includes collection, non_matching_item_from_order1
      refute_includes collection, non_matching_item_from_order2
    end
  ensure
    ActiveRecord::Embedded.config.adapter = @_original_adapter
  end

  test 'query all items with postgres adapter' do
    @_original_adapter = ActiveRecord::Embedded.config.adapter
    ActiveRecord::Embedded.config.adapter = :postgresql

    collection = Item.where(quantity: 1)
    order1 = orders(:one)
    order2 = orders(:one)

    refute_empty collection
    assert_includes collection, order1.items.find_by(quantity: 1)
    assert_includes collection, order2.items.find_by(quantity: 1)
    refute_includes collection, order2.items.find_by(quantity: 2)
  ensure
    ActiveRecord::Embedded.config.adapter = @_original_adapter
  end

  test 'use alternative case for attributes' do
    item = Item.new(
      _parent: Order.new,
      sku: '12345',
      'Quantity' => 1,
      'PRICE_ADJUSTMENTS' => [
        { price: 1 },
        { price: 2 },
        { price: 3 }
      ],
      productAttributes: { foo: 'bar' }
    )

    assert_equal '12345', item.sku
    assert_equal 1, item.quantity
    assert_equal 'bar', item.product_attributes[:foo]
    assert_equal 1, item.price_adjustments.first[:price]
  end

  test 'query within parent object' do
    order = orders(:one)
    item = order.items.first

    assert_equal 3, order.items.count
    assert_equal 2, order.items.offset(1).count
    assert_equal 1, order.items.limit(1).count
    assert_equal 1, order.items.offset(1).limit(2).count
    assert_equal 'SKU456', order.items.order(created_at: :asc).first.sku
    assert_equal 1, order.items.where(sku: 'SKU456').count
    assert_equal item, order.items.find(item.id)
    assert_includes order.items.inspect, item.id
    assert_nil order.items.find_by(sku: 'BOGUS')
    assert_raises(ActiveRecord::RecordNotFound) do
      order.items.find_by!(sku: 'BOGUS')
    end
  end

  test 'add new items' do
    order = orders(:one)
    item = order.items.create(sku: 'SKU666', quantity: 1)

    assert_kind_of Item, order.items.build
    assert item.valid?, item.errors.full_messages.to_sentence
    assert_raises(ActiveRecord::RecordNotSaved) { order.items.create! }
  end

  test 'update existing items' do
    order = orders(:one)
    item = order.items.first

    assert item.update!(sku: 'FOO', quantity: 2)
  end

  test 'cache key' do
    order = orders(:one)
    item = order.items.first

    assert item.send(:max_updated_column_timestamp, %i[foo bar])
  end
end
