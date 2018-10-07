module ActiveRecord
  module Embedded
    class Relation
      include Enumerable

      attr_reader :association, :model, :filters, :sorts

      delegate :to_ary, :empty?, to: :to_a

      def initialize(association: , model: )
        @association = association
        @model = model
        @sorts = {}
        @filters = {}
      end

      def each
        data = model[association.name]
        data.select! do |id, params|
          params.any? { |param, value| filters[param] == value }
        end if filters.any?
        data.sort! do |last_item, next_item|
          last_item <=> next_item
        end if sorts.any?

        data.each { |id, params| yield build(params.merge(id: id)) }
      end

      def build(params = {})
        association.build(model, params)
      end

      def where(filters = {})
        @filters = filters
      end

      def order(attribute, direction = :asc)
        @sorts = { attribute => direction }
      end
    end
  end
end
