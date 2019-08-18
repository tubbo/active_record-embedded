# frozen_string_literal: true

module ActiveRecord
  module Embedded
    # Base class for supported field types. Holds the logic for casting
    # values and reading/writing attributes from the model.
    #
    # @abstract Subclass to define a custom field.
    class Field
      extend Interface

      attr_reader :name, :default

      def initialize(name:, default: nil)
        @name = name
        @default = if default.respond_to? :call
                     default
                   else
                     -> { default }
                   end
      end

      # Whether a default has been set
      def default?
        !@default.nil?
      end

      # Name of the method holding the default value on the object. The
      # default value is kept on the embedded model so that its context
      # can be used to return a default value.
      def default_method_name
        "__#{name}_default__"
      end

      # @!method cast(value)
      #   Cast a given value to this type. Short-circuits when value
      #   passed in is +nil+
      #
      #   @param [Object] value - Value to be casted
      #   @return [Object] Casted value
      #   @abstract Override this method to implement typecasting
      #             behavior.

      # Attempt to +#cast+ this value unless it's nil. Defined to allow
      # fields to customize how data is coerced from Ruby values into
      # the type this field expects. If fields can be coerced naturally
      # in Ruby, e.g. with `#to_s` on most objects, the field does not
      # need to explicitly define this method.
      #
      # @param [Object] value - Value to be coerced
      # @return [Object] Casted value or +nil+
      def coerce(value)
        return if value.nil?

        cast(value)
      end
    end
  end
end
