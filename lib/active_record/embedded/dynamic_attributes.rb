# frozen_string_literal: true

module ActiveRecord
  module Embedded
    # Allow any attribute to be persisted to this embedded model.
    module DynamicAttributes
      # Read and write attributes from the model when they are not
      # explicitly defined on this object. For future method lookups,
      # this will define a +field+ on the object so that its methods will
      # be cached on the embedded object.
      #
      # @param [Symbol] method - Undefined method name
      # @param [Object] value - (optional) Value to set
      # @return [Object] value persisted to the model.
      def method_missing(method, value = nil, *_arguments)
        return super unless respond_to? method

        attribute = method.to_s.delete('=').to_sym
        return self[attribute] if attribute == method

        self[attribute] = cast(attribute, value)
      end

      # Respond to all missing methods.
      #
      # @return [TrueClass]
      def respond_to_missing?(method, include_private = false)
        method.to_s.end_with?('=') || super
      end

      # Override to rescue the error thrown when a field is not defined,
      # and define it on-the-fly so it does not get thrown again.
      def cast(attribute, value)
        super
      rescue Field::NotDefinedError
        self.class.field(attribute, type: value.class)
        super
      end

      # Override to rescue the error thrown when a field is not defined,
      # and define it on-the-fly so it does not get thrown again.
      def coerce(attribute, value)
        super
      rescue Field::NotDefinedError
        self.class.field(attribute, type: value.class)
        super
      end
    end
  end
end
