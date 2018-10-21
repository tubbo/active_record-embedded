# frozen_string_literal: true

module ActiveRecord
  module Embedded
    # Collection of embedded models represented in a similar way
    # as an +ActiveRecord::Relation+. Stores a query in memory
    # which is applied when data is requested, (e.g. the +#each+
    # method is called).
    class Relation
      include Query

      delegate_missing_to :to_a

      # Name of this query, if it matches an index then an index can be
      # used.
      #
      # @return [String]
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

      # Return a subset of the results in this query, up to the first 10.
      #
      # @return [String] Human-readable representation of this object
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
      # @param [Hash] data - Unsorted data
      # @return [Hash] Sorted data
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
      # @param [Hash] data - Unfiltered data
      # @return [Hash] Filtered data
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
