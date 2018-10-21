# frozen_string_literal: true

module ActiveRecord
  module Embedded
    class Index
      # The collection of indexes that exist on an embedded model.
      class Collection
        include Enumerable

        delegate_missing_to :to_a

        def initialize
          @indexes = {}
        end

        # Add a new index.
        def <<(index)
          @indexes[index.name] = index
        end

        # Iterate over all indexes.
        def each
          @indexes.each { |_name, index| yield index }
        end
      end
    end
  end
end
