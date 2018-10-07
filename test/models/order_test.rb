require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  setup do
    @order = Order.new(
      items: [
        { sku: 'SKU123', quantity: 1 },
        { sku: 'SKU456', quantity: 2 }
      ],
      address: {
        name: 'Lester Tester',
        street_1: '123 Fake Street',
        city: 'Fakeadelphia',
        region: 'PA',
        country: 'US'
      }
    )
  end

  test 'embeds many items' do
    assert_kind_of ActiveRecord::Embedded::Relation, @order.items
    refute_empty @order.items
    assert_kind_of Item, @order.items.first
    assert_equal 'SKU456', @order.items.first.sku
  end

  test 'embeds one address' do
    assert_kind_of Address, @order.address
    assert_equal 'Lester Tester', @order.address.name
  end

  test 'reads embedded data from the database' do
    order = orders(:one)
    item = order.items.first

    refute_empty order.items
    assert_kind_of Item, item
    assert_equal 'SKU456', item.sku
    assert_includes item.inspect, '@sku=SKU456'
    assert_includes item.inspect, '@quantity=2'
    assert item.persisted?
  end

  test 'filter query on params' do
    order = orders(:one)
    items = order.items.where(quantity: 1)
    skus = items.map(&:sku)

    assert_kind_of ActiveRecord::Embedded::Relation, items
    refute_empty @order.items
    refute_empty items
    assert_equal 2, items.count
    assert_includes skus, 'SKU123'
    assert_includes skus, 'SKU999'
    refute_includes skus, 'SKU456'
  end

  test 'sort by param in ascending order' do
    order = orders(:one)
    items = order.items.order(sku: :asc)

    assert_kind_of ActiveRecord::Embedded::Relation, items
    assert_equal 'SKU123', items.first.sku
    assert_equal 'SKU999', items.last.sku
  end

  test 'sort by param in descending order' do
    order = orders(:one)
    items = order.items.order(sku: :desc)

    assert_kind_of ActiveRecord::Embedded::Relation, items
    assert_equal 'SKU999', items.first.sku
    assert_equal 'SKU123', items.last.sku
  end

  test 'failure to save' do
    order = orders(:one)

    refute order.items.create.valid?
    assert_raises(ActiveRecord::RecordNotSaved) { order.items.create! }
  end
end
