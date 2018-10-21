# frozen_string_literal: true

module ActiveRecord
  module Embedded
    class Index
      class Collection
        include Enumerable

        def initialize
          @indexes = {}
        end

        def <<(index)
          @indexes[index.name] = index
        end

        def each
          @indexes.each { |_name, index| yield index }
        end
      end
    end
  end
end
