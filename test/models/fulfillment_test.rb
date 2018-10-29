require 'test_helper'

class FulfillmentTest < ActiveSupport::TestCase
  test 'query all items with postgres adapter' do
    @_original_adapter = ActiveRecord::Embedded.config.adapter
    ActiveRecord::Embedded.config.adapter = :sqlserver

    collection = Fulfillment::Package.where(quantity: 1)
    fulfillment1 = fulfillments(:one)
    fulfillment2 = fulfillments(:one)

    refute_empty collection
    assert_includes collection, fulfillment1.items.find_by(quantity: 1)
    assert_includes collection, fulfillment2.items.find_by(quantity: 1)
    refute_includes collection, fulfillment2.items.find_by(quantity: 2)
  ensure
    ActiveRecord::Embedded.config.adapter = @_original_adapter
  end
end
