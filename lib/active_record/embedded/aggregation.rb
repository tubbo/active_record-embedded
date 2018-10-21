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
        # Find an adapter class for the given +config.adapter+. Fall
        # back to the native adapter (e.g., iterating in Ruby) when none
        # can be found.
        #
        # @param [Symbol] id - Current database adapter in use
        # @return [Class]
        def find(id = :native)
          driver = id.to_s.demodulize.classify
          "ActiveRecord::Embedded::Aggregation::#{driver}".constantize
        rescue NameError
          Rails.logger.debug("Database '#{id}' has no embedded adapter")
          Rails.logger.debug('Falling back to native...')
          ActiveRecord::Embedded::Aggregation::Native
        end

        # Shorthand for defining a new aggregation with the correct
        # adapter.
        #
        # @return [Aggregation]
        def create(**options)
          find(Embedded.config.adapter).new(**options)
        end
      end

      # @param [Model] model - Subject of aggregation
      # @param [Hash] filters - Key/value pairs to match results on
      # @param [Hash] sorts - Key/value pairs to sort results with
      # @param [Association] association - Metadata for embedded relationship
      # @param [Integer] limit - Number of results to return
      # @param [Integer] start - Starting point in collection
      def initialize(
        model:, filters: {}, sorts: {}, association: nil, limit: -1, start: 0
      )
        @model = model
        @filters = filters
        @sorts = sorts
        @association = association || parent_model&.association
        @limit_value = limit
        @start_value = start
      end

      # Instantiate the proper model objects for each search result in
      # the query, populating said object with the state of its parent
      # model/association as well.
      #
      # @yield [ActiveRecord::Embedded::Model]
      def each
        results.each do |model, items|
          items.each do |item|
            yield build(model, item)
          end
        end
      end

      # @abstract Override this method to define behavior when
      # aggregation query needs to retrieve results from the database.
      # This should be a 2-dimensional Array with the values +[model, params]+
      #
      # @return [Array<Array>] Search results for query
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
