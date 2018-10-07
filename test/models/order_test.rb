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
end
