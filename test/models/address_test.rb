# frozen_string_literal: true

require 'test_helper'

class AddressTest < ActiveSupport::TestCase
  test 'store address on order' do
    address = Order.create.build_address(
      name: 'Lester Tester',
      street_1: '123 Fake Street',
      city: 'Fakeadelphia',
      region: 'PA',
      country: 'US',
      postal_code: '12345-7890',
      postal_code_validator: /\d{5}(-\d{4})/i,
      kind: :shipping
    )

    assert address.save
  end

  test 'read address from the database' do
    address = Address.new(orders(:one)['address']['data'])

    assert_equal(/\d{5}(-\d{4})/i, address.postal_code_validator)
    assert_equal(:shipping, address.kind)
  end

  test 'inspect attributes' do
    address = orders(:one).address

    assert_includes(Address.new.inspect, 'not initialized')
    assert_includes(address.inspect, address.name)
  end
end
