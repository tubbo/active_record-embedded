# frozen_string_literal: true

require 'test_helper'

class PaymentTest < ActiveSupport::TestCase
  test 'query all tenders with sqlite adapter' do
    @_original_adapter = ActiveRecord::Embedded.config.adapter
    ActiveRecord::Embedded.config.adapter = :sqlite3

    collection = Payment::Tender.where(token: '12345')
    payment1 = payments(:one)
    payment2 = payments(:two)
    payment3 = payments(:three)

    refute_empty collection
    assert_includes collection, payment1.tender
    assert_includes collection, payment2.tender
    refute_includes collection, payment3.tender
  ensure
    ActiveRecord::Embedded.config.adapter = @_original_adapter
  end
end
