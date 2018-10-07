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
        data = data.select do |id, params|
          filters.any? do |filter, value|
            params[filter.to_s] == value
          end
        end unless filters.empty?
        sorts.each do |attribute, direction|
          data = data.sort do |(_, last_item), (_, next_item)|
            if direction == :asc
              last_item[attribute.to_s] <=> next_item[attribute.to_s]
            else
              next_item[attribute.to_s] <=> last_item[attribute.to_s]
            end
          end
        end

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
    end
  end
end
