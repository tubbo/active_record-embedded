module ActiveRecord
  module Embedded
    # Indexes allow for fast searching of embedded model data, taking
    # advantage of faster iteration times over arrays than hashes in the
    # database.
    class Index
      # @param [Hash] query - Query to index on, in the format +{ attribute: :direction }+
      # @param [Boolean] unique - Error when index is already taken
      def initialize(query: {}, options: {})
        @query = query
        @options = options
      end

      # @return [Boolean] Whether this is a unique index.
      def unique?
        @unique
      end

      def values_for(data = [])
        query.map do |attribute, direction|
          items = data.map { |item| item[attribute] }
          items.reverse! if direction == :desc
        end
      end

      def build(data = [])
        {
          options: options,
          values: values_for(data)
        }
      end
    end
  end
end
