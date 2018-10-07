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
        attribute = "#{method}".gsub('=', '').to_sym
        type = if value.class.name.in? Field::TYPES
                 value.class
               elsif value.present?
                 Hash
               end

        self.class.field attribute, type: type
        self[attribute] = value
      end

      # Respond to all missing methods.
      #
      # @return [TrueClass]
      def respond_to_missing?(method, include_private = false)
        method.to_s.end_with?('=') || super
      end
    end
  end
end
