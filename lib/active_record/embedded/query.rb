# frozen_string_literal: true

module ActiveRecord
  module Embedded
    module Query
      include Enumerable

      def association
        raise NotImplementedError, "#{self.class.name}#association"
      end

      def each
        raise NotImplementedError, "#{self.class.name}#each"
      end

      def model
        raise NotImplementedError, "#{self.class.name}#model"
      end

      def filters
        raise NotImplementedError, "#{self.class.name}#filters"
      end

      def sorts
        raise NotImplementedError, "#{self.class.name}#sorts"
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

      def find_by(params = {})
        find_by_index(params) || where(params).first
      end

      def find_by!(params = {})
        find_by(params) || raise(RecordNotFound, params.to_sentence)
      end

      def find_by_index(params = {})
        index = find_index(params)
        return if index.blank?

        values = index['values']
        position = find_position(params, values)
        params = model[association.name]['data'][position] unless position.nil?

        return unless params.present?

        build(params)
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

      def find_position(params, index_values = [])
        params.values.map { |value| index_values.index(value) }.compact.first
      end
    end
  end
end
