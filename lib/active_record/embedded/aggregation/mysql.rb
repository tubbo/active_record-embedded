module ActiveRecord
  module Embedded
    class Aggregation
      class Mysql < Native
        def results
          filters
            .each_with_object(parent.unscoped) { |(key, value), criteria|
              criteria.where("as -> $.data.?", key => value)
            }.map { |model| [model, query_for(model)] }
        end
      end
    end
  end
end
