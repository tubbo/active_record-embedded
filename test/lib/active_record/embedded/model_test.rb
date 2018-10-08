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
        TestModel.fields.keys.each do |key|
          refute Item.fields.key?(key), "#{key} should not be in Item" unless key == :id
        end
      end

      test 'mass assign attributes' do
        @model.attributes = {
          name: 'Test',
          latitude: 79.35,
          longitude: 72,
          amount: 3,
          data: { foo: 'bar', test: true },
          tags: %w(foo bar baz)
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
        assert_nil item.price
      end
    end
  end
end
