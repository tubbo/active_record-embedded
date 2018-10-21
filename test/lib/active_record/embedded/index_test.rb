# frozen_string_literal: true

require 'test_helper'

module ActiveRecord
  module Embedded
    class IndexTest < ActiveSupport::TestCase
      test 'defaults' do
        index = Index.new(attributes: %i[foo])

        assert_equal Index::DEFAULT_DIRECTION, index.direction
        refute index.unique
      end

      test 'name' do
        singular = Index.new(attributes: %i[sku])
        compound = Index.new(attributes: %i[sku quantity])

        assert_equal 'sku', singular.name
        assert_equal 'sku_and_quantity', compound.name
      end

      test 'build' do
        data = [
          {
            id: SecureRandom.uuid,
            sku: 'SKU1'
          },
          {
            id: SecureRandom.uuid,
            sku: 'SKU2'
          }
        ]
        index = Index.new(
          attributes: %i[sku],
          unique: true
        ).build(data)

        assert index[:options][:unique]
        assert_equal Index::DEFAULT_DIRECTION, index[:options][:direction]
        assert_equal %w[SKU1 SKU2], index[:values]
      end
    end
  end
end
