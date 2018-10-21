# frozen_string_literal: true

require 'test_helper'

class AddressTest < ActiveSupport::TestCase
  setup do
    @order = Order.create
    @address = @order.build_address(
      name: 'Lester Tester',
      street_1: '123 Fake Street',
      city: 'Fakeadelphia',
      region: 'PA',
      country: 'US',
      postal_code: '12345-7890',
      postal_code_validator: /\d{5}(-\d{4})/i
    )
  end

  test 'store address on order' do
    assert @address.save
  end
end
