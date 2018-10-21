# frozen_string_literal: true

module ActiveRecord
  module Embedded
    module Model
      # Define indexes for an embedded model, which are used when
      # querying models in the database. Indexes can make searching on
      # known queries much faster, and are modeled after MongoDB/Mongoid
      # indexes and how they work. Also instantiates an
      # +ActiveRecord::Embedded::Index::Collection+ to contain all index
      # configuration for the model.
      module Indexing
        extend ActiveSupport::Concern

        included do
          class_attribute :indexes

          self.indexes = Index::Collection.new
        end

        class_methods do
          # Create a new index on this model.
          #
          # @param [Array] attributes
          # @param [Hash] options
          def index(attributes, **options)
            indexes << Index.new(attributes: attributes, **options)
          end
        end
      end
    end
  end
end
