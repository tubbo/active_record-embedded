module ActiveRecord
  module Embedded
    class Aggregation
      # Driver for JSON/JSONB query support in PostgreSQL. Uses a +@>+
      # query to look for partial JSON in the +data+ Array.
      class Postgresql < Native
        delegate :any?, :empty?, to: :results

        def results
          parent.where("#{as} @> ?", params)
                .map { |record| [record, query_for(record)] }
        end

        private

        def params
          { data: [filters] }.to_json
        end
      end
    end
  end
end
