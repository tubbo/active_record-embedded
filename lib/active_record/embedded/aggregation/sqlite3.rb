# frozen_string_literal: true

module ActiveRecord
  module Embedded
    class Aggregation
      # SQLite3 driver for aggregation queries
      class Sqlite3 < Aggregation
        def results
          models = filtered_results
          models.offset(from) unless from.zero?
          models.limit(to) unless to == -1
          models.map { |model| [model, query_for(model)] }
        end

        private

        def filtered_results
          filters.each_with_object(relation) do |(key, value), criteria|
            criteria.where("json_extract(?, '$.data[*].?') = ?", as, key, value)
          end
        end

        def relation
          parent.unscoped
        end
      end
    end
  end
end
