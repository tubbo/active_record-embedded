# frozen_string_literal: true

module ActiveRecord
  module Embedded
    # Mix this into your embedded model classes to provide
    # +ActiveRecord::Embedded+ functionality, including field/index
    # definition, validations, callbacks, and AR-style fields like
    # timestamps and identifiers.
    module Model
      extend ActiveSupport::Concern

      include ActiveModel::Model
      include Attributes
      include Indexing
      include Fields
      include Persistence
      include Querying
      include Storage

      # @param [ActiveRecord::Base] _parent
      # @param [Embedded::Association] _association - Relationship metadata
      # @param [Hash] attributes - Additional model attributes
      def initialize(_parent: nil, _association: nil, **attributes)
        @_parent = _parent || attributes[parent_model.name]
        @_association = _association
        @attributes = attributes

        run_callbacks :initialize do
          super(attributes)
        end
      end

      # Another record is equal to this model if its +#id+ is the same.
      #
      # @return [Boolean] whether both models' IDs are equal
      def ==(other)
        return false if id.blank?

        id == other&.id
      end
    end
  end
end
