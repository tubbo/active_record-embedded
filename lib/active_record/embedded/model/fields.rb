# frozen_string_literal: true

module ActiveRecord
  module Embedded
    module Model
      module Fields
        extend ActiveSupport::Concern

        included do
          class_attribute :fields

          self.fields ||= {}

          field :id, default: -> { SecureRandom.uuid }
          field :created_at, type: Time, default: -> { Time.current }
          field :updated_at, type: Time, default: -> { Time.current }

          index :id, unique: true
        end

        class_methods do
          # Define an embedded field.
          #
          # @param [Symbol] name - Name of the field
          # @param [Class] type - Class of the field type
          # @param [Object|Proc] default (optional) - Default value
          def field(name, type: String, default: nil)
            fields[name] = field = Field.find(type).new(name, default)
            define_method(name) { self[name] }
            define_method("#{name}=") { |value| self[name] = value }
            return unless field.default?

            define_method(field.default_method_name, field.default)
          end

          # Names of all fields defined on this model.
          #
          # @return [Array<Symbol>]
          def field_names
            fields.keys
          end
        end
      end
    end
  end
end
