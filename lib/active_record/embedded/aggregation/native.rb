module ActiveRecord
  module Embedded
    class Aggregation
      class Native < self
        delegate :empty?, to: :results

        def results
          @results ||= parent.all.map { |model| [model, model.public_send(as).where(@filters)] }
                .select { |model, items| items.any? }
        end
      end
    end
  end
end
