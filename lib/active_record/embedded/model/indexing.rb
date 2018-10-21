# frozen_string_literal: true

module ActiveRecord
  module Embedded
    module Model
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
