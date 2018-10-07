module ActiveRecord
  module Embedded
    class Relation
      include Enumerable

      attr_reader :association, :model, :filters, :sorts

      delegate :to_ary, :empty?, :last, to: :to_a

      def initialize(association: , model: , filters: {}, sorts: {})
        @association = association
        @model = model
        @sorts = sorts
        @filters = filters
      end

      def each
        data = model[association.name]
        data = apply_filters!(data)
        data = apply_sorts!(data)

        data.each { |id, params| yield build(params.merge(id: id)) }
      end

      def build(params = {})
        association.build(model, params)
      end

      def create(params = {})
        association.build(model, params).tap(&:save)
      end

      def create!(params = {})
        association.build(model, params).tap(&:save!)
      end

      def where(filters = {})
        self.class.new(association: @association, model: @model, filters: filters, sorts: @sorts)
      end

      def order(sorts = {})
        self.class.new(association: @association, model: @model, filters: @filters, sorts: sorts)
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
