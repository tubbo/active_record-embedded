require 'test_helper'

class ShipmentTest < ActiveSupport::TestCase
  test 'query all items with mysql adapter' do
    @_original_adapter = ActiveRecord::Embedded.config.adapter
    ActiveRecord::Embedded.config.adapter = :mysql

    collection = Shipment::Item.where(quantity: 1)
    shipment1 = shipments(:one)
    shipment2 = shipments(:one)

    refute_empty collection
    assert_includes collection, shipment1.items.find_by(quantity: 1)
    assert_includes collection, shipment2.items.find_by(quantity: 1)
    refute_includes collection, shipment2.items.find_by(quantity: 2)
  ensure
    ActiveRecord::Embedded.config.adapter = @_original_adapter
  end
end
