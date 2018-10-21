# frozen_string_literal: true

module ActiveRecord
  module Embedded
    # Aggregations are queries made across the entire database, rather
    # than within a certain record. Since aggregations require
    #
    # @abstract Subclass to define a new adapter
    class Aggregation
      include Query

      class << self
        # Find an adapter for the given +config.adapter+
        def find(id = :native)
          "ActiveRecord::Embedded::Aggregation::#{id.to_s.demodulize.classify}".constantize
        rescue NameError
          Rails.logger.debug("No aggregation found for adapter '#{id}'")
          ActiveRecord::Embedded::Aggregation::Native
        end

        # Shorthand for defining a new aggregation with the correct
        # adapter.
        def create(**options)
          find(Embedded.config.adapter).new(**options)
        end
      end

      def initialize(model:, filters: {}, sorts: {}, association: nil, limit: -1, start: 0)
        @model = model
        @filters = filters
        @association = association || parent_model&.association
        @limit_value = limit
        @start_value = start
      end

      def each
        results.each do |model, items|
          items.each do |item|
            yield build(model, item)
          end
        end
      end

      def results
        raise NotImplementedError, "#{self.class.name}#results"
      end

      def inspect
        entries = if @limit_value == -1
                    take(11).map!(&:inspect)
                  else
                    take([@limit_value, 11].compact.min).map!(&:inspect)
                  end
        entries[10] = '...' if entries.size == 11

        "#<#{self.class.name} [#{entries.join(', ')}]>"
      end

      protected

      attr_reader :model
      attr_reader :filters
      attr_reader :sorts
      attr_reader :association

      delegate :parent_model, to: :@model
      delegate :as, to: :parent_model
      delegate :build, to: :association

      # Parent model class of the embedded model.
      #
      # @return [ActiveRecord::Base]
      def parent
        parent_model.embedded_class
      end
    end
  end
end
