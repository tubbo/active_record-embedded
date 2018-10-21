# frozen_string_literal: true

module ActiveRecord
  module Embedded
    class Aggregation
      class Native < Aggregation
        delegate :empty?, to: :results

        def query_for(model)
          model.public_send(as).where(@filters)
        end

        def results
          @results ||= parent
                       .all
                       .map { |model| [model, query_for(model)] }
                       .select { |_model, items| items.any? }
        end
      end
    end
  end
end
