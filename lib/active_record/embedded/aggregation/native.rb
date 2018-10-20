module ActiveRecord
  module Embedded
    class Aggregation
      class Native < self
        delegate :empty?, to: :results


        def query_for(model)
          model.public_send(as).where(@filters)
        end

        def results
          @results ||= parent
                        .all
                        .map { |model| [model, query_for(model)] }
                        .select { |model, items| items.any? }
        end
      end
    end
  end
end
