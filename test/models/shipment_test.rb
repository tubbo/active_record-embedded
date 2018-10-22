require 'test_helper'

class ShipmentTest < ActiveSupport::TestCase
  test 'query all items with mysql adapter' do
    @_original_adapter = ActiveRecord::Embedded.config.adapter
    ActiveRecord::Embedded.config.adapter = :mysql

    order1 = orders(:one)
    order2 = orders(:one)
    shipment1 = Shipment.create!(
      order_id: order1.id,
      items: order1.items.map do |item|
        {
          sku: item.sku,
          quantity: item.quantity,
          shipping_price: 1.99
        }
      end
    )
    shipment2 = Shipment.create!(
      order_id: order2.id,
      items: order2.items.map do |item|
        {
          sku: item.sku,
          quantity: item.quantity,
          shipping_price: 1.99
        }
      end
    )
    collection = Shipment::Item.where(quantity: 1)

    refute_empty collection
    assert_includes collection, shipment1.items.find_by(quantity: 1)
    assert_includes collection, shipment2.items.find_by(quantity: 1)
    refute_includes collection, shipment2.items.find_by(quantity: 2)
  ensure
    ActiveRecord::Embedded.config.adapter = @_original_adapter
  end
end
