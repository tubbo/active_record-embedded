# frozen_string_literal: true

require 'test_helper'

module ActiveRecord
  module Embedded
    class RelationTest < ActiveSupport::TestCase
      setup do
        @model = Minitest::Mock.new
        @association = Minitest::Mock.new
        @query = Relation.new(
          association: @association,
          model: @model
        )
      end

      test 'filter by attributes' do
        filtered = @query.where(foo: 'bar', bar: 'baz')

        assert_equal 'bar', filtered.filters[:foo]
        assert_equal 'baz', filtered.filters[:bar]
      end

      test 'sort in descending order' do
        descending = @query.order(foo: :desc)

        assert_equal :desc, descending.sorts[:foo]
      end

      test 'sort in ascending order' do
        ascending = @query.order(foo: :asc)

        assert_equal :asc, ascending.sorts[:foo]
      end

      test 'build model' do
        @association.expect(:build, Foo.new(foo: 'bar'), [@model, { foo: 'bar' }])
        record = @query.build(foo: 'bar')

        assert_kind_of Foo, record
        assert_equal 'bar', record.foo
      end
    end
  end
end
