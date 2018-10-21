# frozen_string_literal: true

module ActiveRecord
  module Embedded
    # Collection of embedded models represented in a similar way
    # as an +ActiveRecord::Relation+. Stores a query in memory
    # which is applied when data is requested, (e.g. the +#each+
    # method is called).
    class Relation
      include Query

      attr_reader :association, :model, :filters, :sorts,
                  :limit_value, :start_value

      delegate_missing_to :to_a

      # @param [ActiveRecord::Embedded::Association] association
      # @param [ActiveRecord::Base] model - Parent model for persistence
      # @param [Hash] filters - Query filters to apply
      # @param [Hash] sorts - Sort data to apply
      def initialize(
        association:, model:, filters: {}, sorts: {}, limit: -1, start: 0
      )
        @association = association
        @model = model
        @sorts = sorts
        @filters = filters
        @limit_value = limit
        @start_value = start
      end

      def query_name
        if filters.one?
          filters.keys.first.to_s
        else
          filters.keys.join('_and_')
        end
      end

      # Apply query and iterate over each model in the collection.
      #
      # @yields [ActiveRecord::Embedded::Model] for each datum
      def each
        if model[association.name]['index'].key?(query_name)
          values = model[association.name]['index'][query_name]['values']
          indexes = params.values.map { |value| values.index(value) }
          data = indexes.map { |index| model[association.name]['data'][index] }
        else
          data = model[association.name]['data']
          data = apply_filters!(data)
          data = apply_sorts!(data)
        end

        data.each { |params| yield build(params) }
      end

      def inspect
        entries = if limit_value == -1
                    take(11).map!(&:inspect)
                  else
                    take([limit_value, 11].compact.min).map!(&:inspect)
                  end
        entries[10] = '...' if entries.size == 11

        "#<#{self.class.name} [#{entries.join(', ')}]>"
      end

      private

      # @private
      def apply_sorts!(data)
        sorts.each do |attribute, direction|
          data = data.sort do |last_item, next_item|
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

        data.select do |params|
          filters.any? do |filter, value|
            params[filter.to_s] == value
          end
        end
      end
    end
  end
end
