module ActiveRecord
  module Embedded
    class Aggregation
      class Postgresql < Native
        delegate :any?, :empty?, to: :results

        def results
          parent.where("#{as} @> ?", params)
                .map { |model| [model, query_for(model)] }
        end

        private

        def params
          { data: [filters] }.to_json
        end
      end
    end
  end
end
