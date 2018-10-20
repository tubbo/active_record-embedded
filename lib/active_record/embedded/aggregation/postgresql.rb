module ActiveRecord
  module Embedded
    class Aggregation
      class Postgresql < self
        delegate :any?, :empty?, to: :results

        protected

        def results
          criteria = parent.unscoped
          filters.each do |filter, value|
            criteria = criteria.where(query(filter), value)
          end
          criteria
        end

        private

        def query(filter)
          "#{as}->'#{filter}' = ?"
        end
      end
    end
  end
end
