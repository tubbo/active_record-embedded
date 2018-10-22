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
      include ActiveRecord::Integration

      included do
        self.cache_versioning = ActiveRecord::Base.cache_versioning
      end

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

      # Prefix the embedded model's cache key with the parent model's
      # cache key.
      #
      # @return [String] a stable cache key that can be used to identify
      #                  this embedded record.
      def cache_key(*timestamp_names)
        "#{_parent.cache_key}/#{super}"
      end

      private

      def max_updated_column_timestamp(_names = [])
        [created_at, updated_at].max
      end
    end
  end
end
