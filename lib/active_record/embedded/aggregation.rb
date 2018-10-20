module ActiveRecord
  module Embedded
    # Aggregations are queries made across the entire database, rather
    # than within a certain record. Since aggregations require
    #
    # @abstract Subclass to define a new adapter
    class Aggregation
      include Query

      class << self
        delegate :config, to: Embedded

        # Find an adapter for the given +config.adapter+
        def find(id)
          "ActiveRecord::Embedded::Aggregation::#{id.to_s.demodulize.classify}".constantize
        end

        # Shorthand for defining a new aggregation with the correct
        # adapter.
        def create(**options)
          find(config.adapter).new(**options)
        end
      end

      def initialize(model:, filters: {}, sorts: {}, association: nil)
        @model = model
        @filters = filters
        @association = association || parent_model&.association
      end

      def each
        results.each do |model, items|
          items.each do |item|
            yield build(model, item)
          end
        end
      end

      protected

      attr_reader :model
      attr_reader :filters
      attr_reader :sorts
      attr_reader :association

      delegate :parent_model, to: :@model
      delegate :as, to: :parent_model
      delegate :build, to: :association

      # @!method results
      #   @abstract Implement this method

      # Parent model class of the embedded model.
      #
      # @return [ActiveRecord::Base]
      def parent
        parent_model.embedded_class
      end
    end
  end
end
