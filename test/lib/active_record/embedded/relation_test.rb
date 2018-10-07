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
        assert_equal @query, @query.where(foo: 'bar', bar: 'baz')
        assert_equal 'bar', @query.filters[:foo]
        assert_equal 'baz', @query.filters[:bar]
      end

      test 'sort in descending order' do
        assert_equal @query, @query.order(foo: :desc)
        assert_equal :desc, @query.sorts[:foo]
      end

      test 'sort in ascending order' do
        assert_equal @query, @query.order(foo: :asc)
        assert_equal :asc, @query.sorts[:foo]
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
