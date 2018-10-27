# frozen_string_literal: true

module ActiveRecord
  module Embedded
    module Model
      # Functionality for storing and casting attributes on an embedded
      # model. Uses the configured +fields+ for the given model to
      # cast/coerce attributes into and out of (respectively) the
      # database.
      module Attributes
        extend ActiveSupport::Concern

        included do
          attr_reader :attributes

          alias_method :has_attribute?, :key?
          alias_method :read_attribute, :[]
          alias_method :write_attribute, :[]=
        end

        # Read an attribute from the model.
        #
        # @param [Symbol] key - Attribute name
        # @return [Object] Coerced value of this attribute, or +nil+ if
        #                  it cannot be found.
        def [](key)
          value = attributes[key.to_sym]
          ivar = "@#{key}"

          return if value.nil?
          return instance_variable_get(ivar) if instance_variable_defined?(ivar)

          instance_variable_set(ivar, coerce(key, value))
        end

        # Write an attribute to the model.
        #
        # @param [Symbol] key - Attribute name
        # @param [Object] value - Value of this attribute
        def []=(key, value)
          attributes[key.to_sym] = cast(key, value)
        end

        # Whether the given attribute exists on this model.
        def key?(key)
          attributes.key?(key.to_sym)
        end

        # @return [String]
        def inspect
          inspection = if @attributes
                         self.class.field_names.collect do |name|
                           if has_attribute?(name)
                             "#{name}: #{attribute_for_inspect(name)}"
                           end
                         end.compact.join(', ')
                       else
                         'not initialized'
                       end
          "#<#{self.class} #{inspection}>"
        end

        # Cast attributes before assignment using
        # +ActiveModel::AttributeMethods+.
        #
        # @param [Hash] attrs - Attributes to assign
        # @return [Hash] casted attributes
        def assign_attributes(attrs = {})
          super cast_attributes(attrs)
        end

        private

        CAMEL_CASED = /[A-Z][a-z]|\s/
        SCREAMING_SNAKE_CASED = /[A-Z]_/

        # Create a single attributes Hash from uncased string-key
        # attributes and cased symbol-key attributes.
        #
        # @private
        def amalgamate_attributes(strs = {}, syms = {})
          syms.merge(strs).each_with_object({}) do |(key, value), attributes|
            param = if key.to_s.match?(SCREAMING_SNAKE_CASED)
                      key.to_s.downcase.to_sym
                    elsif key.to_s.match?(CAMEL_CASED)
                      key.to_s.camelize(:upper).underscore.to_sym
                    else
                      key.to_sym
                    end
            attributes[param] = value
          end
        end

        # @private
        def attribute_for_inspect(attr_name)
          value = read_attribute(attr_name)

          if value.is_a?(String) && value.length > 50
            "#{value[0, 50]}...".inspect
          elsif value.is_a?(Date) || value.is_a?(Time)
            %("#{value.to_s(:db)}")
          else
            value.inspect
          end
        end

        # @private
        def cast_attributes(attrs = {})
          attrs.symbolize_keys.each_with_object({}) do |(attr, value), casted|
            casted[attr] = cast(attr, value)
          end
        end

        # @private
        def cast(attribute, value = nil)
          field = self.class.fields[attribute]
          raise Field::NotDefinedError, attribute if field.blank?

          casted_value = field.cast(value) unless value.blank?
          return public_send(field.default_method_name) if casted_value.blank?

          casted_value
        end

        # @private
        def coerce(attribute, value = nil)
          field = self.class.fields[attribute.to_sym]
          raise Field::NotDefinedError, attribute if field.blank?

          coerced_value = field.coerce(value) unless value.blank?
          return public_send(field.default_method_name) if coerced_value.blank?

          coerced_value
        end
      end
    end
  end
end
