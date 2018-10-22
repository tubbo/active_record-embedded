# frozen_string_literal: true

module ActiveRecord
  module Embedded
    class Aggregation
      # Driver for JSON/JSONB query support in PostgreSQL. Uses a +@>+
      # query to look for partial JSON in the +data+ Array.
      class Postgresql < Aggregation
        delegate :any?, :empty?, to: :results

        def results
          criteria = parent.where("#{as} @> ?", params)
          criteria = criteria.offset(from) unless from.zero?
          criteria = criteria.limit(to) unless to == -1
          criteria.map { |record| [record, query_for(record)] }
        end

        private

        def params
          { data: [filters] }.to_json
        end
      end
    end
  end
end
