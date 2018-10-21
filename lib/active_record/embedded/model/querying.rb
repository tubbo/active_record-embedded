# frozen_string_literal: true

module ActiveRecord
  module Embedded
    module Model
      # Aggregation logic for this model. Defines top-level query
      # methods like +.where+ and +.order+ as well as an +.aggregate+
      # method for defining your own aggregations.
      module Querying
        extend ActiveSupport::Concern

        class_methods do
          delegate_missing_to :aggregate

          # Filter items by a given set of parameters, in the form of
          # +:key => "value"+.
          #
          # @param [Hash] filters - Filtering options
          # @return [ActiveRecord::Embedded::Aggregation] Query Object
          def where(filters = {})
            aggregate(where: filters)
          end

          # Sort items by a given set of parameters, in the form of
          # +:attribute => :direction+.
          #
          # @example Sort user addresses by creation date
          #   User::Address.order(created_at: :asc)
          # @param [Hash] sorts - Sorting options
          # @return [ActiveRecord::Embedded::Aggregation] Query Object
          def order(sorts = {})
            aggregate(order: sorts)
          end

          # Define a new aggregation query.
          #
          # @param [Hash] where - Filtering options
          # @param [Hash] order - Sorting options
          # @return [ActiveRecord::Embedded::Aggregation] Query Object
          def aggregate(where: {}, order: {})
            association = parent_model&.association

            Aggregation.create(
              model: self,
              filters: where,
              sorts: order,
              association: association
            )
          end
        end
      end
    end
  end
end
