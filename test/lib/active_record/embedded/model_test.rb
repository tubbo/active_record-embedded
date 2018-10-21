# frozen_string_literal: true

require 'test_helper'

class TestModel
  include ActiveRecord::Embedded::Model

  embedded_in :foo

  field :name
  field :latitude, type: Float
  field :longitude, type: Float
  field :amount, type: Integer
  field :data, type: Hash
  field :tags, type: Array
end

module ActiveRecord
  module Embedded
    class ModelTest < ActiveSupport::TestCase
      setup do
        @model = TestModel.new(_parent: Foo.new(foo: 'bar'))
      end

      test 'fields' do
        default_keys = %i[id created_at updated_at]
        TestModel.fields.keys.each do |key|
          unless key.in? default_keys
            refute Item.fields.key?(key), "#{key} should not be in Item"
          end
        end
      end

      test 'mass assign attributes' do
        @model.attributes = {
          name: 'Test',
          latitude: 79.35,
          longitude: 72,
          amount: 3,
          data: { foo: 'bar', test: true },
          tags: %w[foo bar baz]
        }

        assert_equal 'Test', @model.name
        assert_equal 79.35, @model.latitude
        assert_equal 72.0, @model.longitude
        assert_equal 3, @model.amount
        assert_equal 'bar', @model.data[:foo]
        assert @model.data[:test]
        assert_includes @model.tags, 'foo'
        assert_includes @model.tags, 'bar'
        assert_includes @model.tags, 'baz'
      end

      test 'save embedded relation' do
        order = orders(:one)
        item = order.items.create(sku: 'SKU666', quantity: 1)

        assert item.valid?, item.errors.full_messages.to_sentence
        assert_equal 'SKU666', item.sku
        assert_equal 1, item.quantity
        assert_equal 0.0, item.price
        assert_nil item.placed_at
      end

      test 'update timestamps when saved' do
        order = orders(:one)
        item = order.items.create(sku: 'SKU666', quantity: 1)
        original_update_time = item.updated_at

        sleep 1
        assert item.update(quantity: 2)
        refute_equal item.updated_at, original_update_time
      end

      test 'destroy embedded model' do
        order = orders(:one)
        item = order.items.first
        address = order.address

        refute_nil item, 'item'
        refute_nil address, 'address'
        assert item.destroy!
        assert address.destroy!
        refute_includes order.reload.items, item
      end
    end
  end
end
