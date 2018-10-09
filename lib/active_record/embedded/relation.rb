module ActiveRecord
  module Embedded
    # Collection of embedded models represented in a similar way
    # as an +ActiveRecord::Relation+. Stores a query in memory
    # which is applied when data is requested, (e.g. the +#each+
    # method is called).
    class Relation
      include Enumerable

      attr_reader :association, :model, :filters, :sorts

      delegate :to_ary, :empty?, :last, to: :to_a

      # @param [ActiveRecord::Embedded::Association] association
      # @param [ActiveRecord::Base] model - Parent model for persistence
      # @param [Hash] filters - Query filters to apply
      # @param [Hash] sorts - Sort data to apply
      def initialize(association: , model: , filters: {}, sorts: {})
        @association = association
        @model = model
        @sorts = sorts
        @filters = filters
      end

      # Apply query and iterate over each model in the collection.
      #
      # @yields [ActiveRecord::Embedded::Model] for each datum
      def each
        data = model[association.name]
        data = apply_filters!(data)
        data = apply_sorts!(data)

        data.each { |id, params| yield build(params.merge(id: id)) }
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

      private

      # @private
      def apply_sorts!(data)
        sorts.each do |attribute, direction|
          data = data.sort do |(_, last_item), (_, next_item)|
            if direction == :asc
              last_item[attribute.to_s] <=> next_item[attribute.to_s]
            else
              next_item[attribute.to_s] <=> last_item[attribute.to_s]
            end
          end
        end

        data
      end

      # @private
      def apply_filters!(data)
        return data if filters.empty?

        data = data.select do |id, params|
          filters.any? do |filter, value|
            params[filter.to_s] == value
          end
        end
      end
    end
  end
end
