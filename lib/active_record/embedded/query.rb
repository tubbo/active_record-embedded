# frozen_string_literal: true

module ActiveRecord
  module Embedded
    # Interface for querying embedded models. Implemented by the
    # +ActiveRecord::Embedded::Relation+ and
    # +ActiveRecord::Embedded::Aggregation+ objects, and provides the
    # various SQL methods.
    module Query
      extend ActiveSupport::Concern

      include Enumerable

      included do
        attr_reader :model, :filters, :sorts, :association,
                    :limit_value, :start_value
      end

      # @param [Model] model - Subject of aggregation
      # @param [Hash] filters - Key/value pairs to match results on
      # @param [Hash] sorts - Key/value pairs to sort results with
      # @param [Association] association - Metadata for embedded relationship
      # @param [Integer] limit - Number of results to return
      # @param [Integer] start - Starting point in collection
      def initialize(
        model:, filters: {}, sorts: {}, association: nil, limit: -1, start: 0
      )
        @model = model
        @filters = filters
        @sorts = sorts
        @association = association
        @limit_value = limit
        @start_value = start
      end

      # Instantiate a new model in this collection without persisting.
      #
      # @param [Hash] params - Attributes to build the model with.
      # @return [ActiveRecord::Embedded::Model]
      def build(params = {})
        association.build(model, params)
      end

      # Create a new model in this collection.
      #
      # @param [Hash] params - Attributes to build the model with.
      # @return [ActiveRecord::Embedded::Model]
      def create(params = {})
        association.build(model, params).tap(&:save)
      end

      # Create a new model in this collection, and throw an exception if
      # the operation fails.
      #
      # @param [Hash] params - Attributes to build the model with.
      # @return [ActiveRecord::Embedded::Model]
      def create!(params = {})
        association.build(model, params).tap(&:save!)
      end

      # Filter this collection by the given set of key/value pairs.
      #
      # @param [Hash] filters - Key/value pairs to filter by
      # @return [ActiveRecord::Embedded::Relation]
      def where(filters = {})
        self.class.new(
          association: association,
          model: model,
          filters: filters,
          sorts: sorts
        )
      end

      # Order this collection by the given set of keys. Values are
      # the direction, +:desc+ or +:asc+.
      #
      # @param [Hash] sorts - Key/direction pairs to sort by
      # @return [ActiveRecord::Embedded::Relation]
      def order(sorts = {})
        self.class.new(
          association: association,
          model: model,
          filters: filters,
          sorts: sorts
        )
      end

      # Find a model by the given params. Uses an index if possible,
      # otherwise performs a full table scan unless +config.scan_tables+
      # is set to false.
      #
      # @return [ActiveRecord::Embedded::Model] or +nil+ if nothing found
      # @see ActiveRecord::Embedded::Query#find_by_index for more information
      #      on what happens when indexes are used
      def find_by(params = {})
        find_by_index(params) || where(params).first
      end

      # Find a model by the given params. Uses an index if possible,
      # otherwise performs a full table scan unless +config.scan_tables+
      # is set to false. Throws an error when no record can be found by
      # any means.
      #
      # @return [ActiveRecord::Embedded::Model] if found
      # @throws [ActiveRecord::RecordNotFound] when not found
      def find_by!(params = {})
        find_by(params) || raise(RecordNotFound, params.to_sentence)
      end

      # Find a given model in the database by its ID.
      #
      # @param [String] ID - Unique ID for the model you wish to find
      # @return [ActiveRecord::Embedded::Model] or +nil+ if none can be found
      def find(id)
        find_by_index(id: id)
      end

      # Find a given model in the database by its ID. Throw an error
      # when it cannot be found.
      #
      # @param [String] ID - Unique ID for the model you wish to find
      # @return [ActiveRecord::Embedded::Model] or +nil+ if none can be found
      def find!(id)
        find(id) || raise(RecordNotFound, id)
      end

      private

      # Find a given model by its index.
      #
      # @private
      def find_by_index(params = {})
        index = find_index(params)
        return if index.blank?

        values = index['values']
        position = find_position(params, values)
        params = model[association.name]['data'][position] unless position.nil?

        return unless params.present?

        build(params)
      end

      # Find an index for the given query.
      #
      # @private
      # @return [Hash] or +nil+ if nothing can be found.
      def find_index(params = {})
        name = if params.one?
                 params.keys.first.to_s
               else
                 params.keys.join('_and_')
               end
        index = model[association.name]['index'][name]

        return if index.blank? && Embedded.config.scan_tables

        raise NoSolutionsError, name if index.blank?

        index
      end

      # Find position of data in the array.
      #
      # @private
      # @param [Hash] params
      # @param [Array] index_values
      def find_position(params, index_values = [])
        params.values.map { |value| index_values.index(value) }.compact.first
      end
    end
  end
end
