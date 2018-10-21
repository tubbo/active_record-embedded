# frozen_string_literal: true

require 'test_helper'

module ActiveRecord
  module Embedded
    class AssociationTest < ActiveSupport::TestCase
      setup do
        @association = Association.new(
          name: :foo,
          custom_option: :bar
        )
      end

      test 'attributes' do
        assert_equal :foo, @association.name
        assert_equal 'Foo', @association.class_name
        assert_equal Foo, @association.embedded_class
      end

      test 'build' do
        parent = MiniTest::Mock.new(:== => true)
        embedded = @association.build(parent, foo: 'bar')

        assert_equal parent, embedded.parent
        assert_equal @association, embedded.association
        assert_equal 'bar', embedded.foo
      end

      test 'interface methods' do
        model = MiniTest::Mock.new
        params = { foo: 'bar' }
        data = [params]
        id = SecureRandom.uuid

        assert_raises(NotImplementedError) { @association.query(model) }
        assert_raises(NotImplementedError) { @association.find(model, id) }
        assert_raises(NotImplementedError) do
          @association.assign(model, params)
        end
        assert_raises(NotImplementedError) do
          @association.create(model, params)
        end
        assert_raises(NotImplementedError) do
          @association.update(model, params)
        end
        assert_raises(NotImplementedError) { @association.destroy(model) }
        assert_raises(NotImplementedError) { @association.index(model, data) }
      end
    end
  end
end
