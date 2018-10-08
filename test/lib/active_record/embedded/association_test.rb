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
        id = SecureRandom.uuid

        assert_raises(NotImplementedError) { @association.query(model) }
        assert_raises(NotImplementedError) { @association.find(model, id) }
        assert_raises(NotImplementedError) { @association.assign(model, params) }
        assert_raises(NotImplementedError) { @association.create(model, params) }
        assert_raises(NotImplementedError) { @association.update(model, params) }
        assert_raises(NotImplementedError) { @association.destroy(model) }
      end
    end
  end
end
