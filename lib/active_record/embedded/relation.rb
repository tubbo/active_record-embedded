module ActiveRecord
  module Embedded
    class Relation
      include Enumerable

      attr_reader :association, :model

      delegate :to_ary, to: :to_a

      def initialize(association: , model: )
        @association = association
        @model = model
      end

      def each
        data.each { |id, params| yield build(params.merge(id: id)) }
      end

      def build(params = {})
        association.build(model, params)
      end

      private

      def filtered
        self
      end

      def sorted
        self
      end

      def data
        @data ||= model[association.name]
      end
    end
  end
end
