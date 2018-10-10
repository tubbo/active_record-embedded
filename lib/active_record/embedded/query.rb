module ActiveRecord
  module Embedded
    module Query
      include Enumerable

      def association
        raise NotImplementedError
      end

      def each
        raise NotImplementedError
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
          association: @association,
          model: @model,
          filters: filters,
          sorts: @sorts
        )
      end

      # Order this collection by the given set of keys. Values are
      # the direction, +:desc+ or +:asc+.
      #
      # @param [Hash] sorts - Key/direction pairs to sort by
      # @return [ActiveRecord::Embedded::Relation]
      def order(sorts = {})
        self.class.new(
          association: @association,
          model: @model,
          filters: @filters,
          sorts: sorts
        )
      end

      def find_by(params = {})
        where(params).first
      end

      def find_by!(params = {})
        where(params).first || raise(RecordNotFound, params.to_sentence)
      end

      # Find a given model in the database by its ID.
      #
      # @param [String] ID - Unique ID for the model you wish to find
      # @return [ActiveRecord::Embedded::Model] or +nil+ if none can be found
      def find(id)
        params = model[association.name][id]
        return unless params.present?

        build(params)
      end

      # Find a given model in the database by its ID. Throw an error
      # when it cannot be found.
      #
      # @param [String] ID - Unique ID for the model you wish to find
      # @return [ActiveRecord::Embedded::Model] or +nil+ if none can be found
      def find!(id)
        find(id) || raise(RecordNotFound, id)
      end
    end
  end
end
