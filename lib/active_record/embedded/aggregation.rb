# frozen_string_literal: true

module ActiveRecord
  module Embedded
    # Aggregations are queries made across the entire database, rather
    # than within a certain record. These queries are used when
    # the ActiveRecord API is used on the class level, e.g.
    # `Model.where`. Aggregation queries can become resource-intensive when
    # performed using native Ruby, therefore special adapters are
    # included for databases whose query languages support JSON and/or
    # embedded, schema-less attributes.
    #
    # Adapters of this kind are subclasses of an Aggregation, and all
    # they need to do is implement the `#results` method to produce
    # a 2-dimensional Array of embedded records.
    #
    # @abstract Subclass to define a new adapter
    class Aggregation
      include Query
      extend Interface

      class_attribute :serialized
      self.serialized = false if serialized.nil?

      delegate :parent_model, to: :model
      delegate :as, to: :parent_model
      delegate :build, to: :association
      delegate :any?, :empty?, :join, to: :results

      def initialize(*_args)
        super
        @association ||= parent_model&.association
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

      protected

      # Parent model class of the embedded model.
      #
      # @private
      # @return [ActiveRecord::Base]
      def parent
        parent_model.embedded_class
      end

      # Query for filters and sorts on the given model.
      #
      # @private
      def query_for(record)
        record.public_send(as).where(filters)
      end
    end
  end
end
