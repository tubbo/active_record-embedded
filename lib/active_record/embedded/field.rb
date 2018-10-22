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

      # Name of the method holding the default value.
      def default_method_name
        "__#{name}_default__"
      end

      # Cast a given value to this type. Short-circuits when value
      # passed in is +nil+
      #
      # @param [Object] value - Value to be casted
      # @return [Object] Casted value or +nil+ if value was nil.
      # @abstract Override this method to implement typecasting
      #           behavior.
      def cast(value)
        raise NotImplementedError, "#{self.class.name}#cast"
      end

      # Attempt to +#cast+ this value unless it's nil.
      def coerce(value)
        return if value.nil?

        cast(value)
      end
    end
  end
end
