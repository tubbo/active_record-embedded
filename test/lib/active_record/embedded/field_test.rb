# frozen_string_literal: true

require 'test_helper'

module ActiveRecord
  module Embedded
    # Base class for supported field types. Responsible for casting
    # values.
    class FieldTest < ActiveSupport::TestCase
      test 'types' do
        assert_includes(Field.types, 'String')
        assert_includes(Field.types, 'Integer')
        assert_includes(Field.types, 'Float')
        assert_includes(Field.types, 'Hash')
        assert_includes(Field.types, 'Array')
        assert_includes(Field.types, 'Boolean')
      end

      test 'find' do
        assert_equal Field::Boolean, Field.find(Boolean)
        assert_equal Field::String, Field.find(String)
        assert_equal Field::String, Field.find(:String)
        assert_equal Field::Integer, Field.find('Integer')
        assert_raises(TypeError) { Field.find('Bogus') }
        assert_raises(TypeError) { Field.find(Object) }
      end

      test 'cast' do
        field = Field.new(name: :name, default: -> { 'Foo' })
        str = Field::String.new(name: :foo)
        int = Field::Integer.new(name: :foo)
        float = Field::Float.new(name: :foo)
        hash = Field::Hash.new(name: :foo)
        arr = Field::Array.new(name: :foo)
        bool = Field::Boolean.new(name: :foo)
        params = { foo: 'bar' }

        assert_raises(NotImplementedError) { field.cast(nil) }
        assert bool.cast(true)
        assert_equal 'foo', str.cast('foo')
        assert_equal 1, int.cast('1')
        assert_equal 1.0, float.cast(1)
        assert_equal params, hash.cast(params.to_a)
        assert_equal %w[foo bar baz], arr.cast(%w[foo bar baz])
      end
    end
  end
end
