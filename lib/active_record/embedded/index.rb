module ActiveRecord
  module Embedded
    # Indexes allow for fast searching of embedded model data, taking
    # advantage of faster iteration times over arrays than hashes in the
    # database.
    class Index
      DEFAULT_DIRECTION = :asc

      attr_reader :attributes, :direction, :unique

      # @param [Array] attributes
      # @param [Symbol] direction - Either +:desc+ or +:asc+.
      # @param [Boolean] unique - Error when index is already taken
      def initialize(attributes: , direction: DEFAULT_DIRECTION, unique: false)
        @attributes = Array(attributes)
        @direction = direction
        @unique = unique
      end

      def name
        return attributes.first.to_s if attributes.one?
        attributes.join('_and_')
      end

      def build(data = [])
        {
          options: {
            direction: direction,
            unique: unique
          },
          values: values_for(data)
        }
      end

      private

      def values_for(data = [])
        attributes.flat_map do |attribute|
          data.map { |item| item[attribute] }
              .tap { |items| items.reverse! if direction != DEFAULT_DIRECTION }
        end
      end
    end
  end
end
