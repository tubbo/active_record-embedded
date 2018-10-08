module ActiveRecord
  module Embedded
    # Base class for supported field types. Holds the logic for casting
    # values and reading/writing attributes from the model.
    #
    # @abstract Subclass to define a custom field.
    class Field
      attr_reader :name, :default

      def initialize(name, default)
        @name = name
        @default = default
      end

      # All type names, which are subclasses of this object.
      #
      # @return [Array<String>]
      def self.types
        subclasses.map { |field| field.name.demodulize }
      end

      # Find a field object by its given type name.
      #
      # @return [ActiveRecord::Embedded::Field] Subclass of +Field+
      def self.find(type)
        class_name = type.to_s.demodulize.classify
        "ActiveRecord::Embedded::Field::#{class_name}".constantize
      rescue NameError
        raise TypeError, type
      end

      # Cast a given value to this type. Short-circuits when value
      # passed in is +nil+
      #
      # @param [Object] value - Value to be casted
      # @return [Object] Casted value or +nil+ if value was nil.
      def cast(value = nil)
        return if value.nil?
        cast!(value)
      end

      # @param [Object] value - Value to be casted.
      # @abstract Override this method to implement typecasting
      #           behavior.
      def cast!(value)
        raise NotImplementedError
      end
    end
  end
end
