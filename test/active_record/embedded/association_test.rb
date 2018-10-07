require 'test_helper'

class Foo
  attr_reader :parent, :association, :foo

  def initialize(_parent: , _association: , foo: )
    @parent = _parent
    @association = _association
    @foo = foo
  end
end

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

        assert_raises(NotImplementedError) { @association.find(model) }
        assert_raises(NotImplementedError) { @association.create(model, params) }
        assert_raises(NotImplementedError) { @association.update(model, params) }
        assert_raises(NotImplementedError) { @association.destroy(model) }
      end
    end
  end
end
