# frozen_string_literal: true

module ActiveRecord
  module Embedded
    class Aggregation
      # Describe how to aggregate over embedded data across
      # multiple parent models using Ruby's +Enumerable+ methods.
      # Because this causes multiple iterations over an object, it's
      # best to use a database-specific adapter such as +:postgresql+
      # or +:mysql+ if you need aggregations.
      class Native < Aggregation
        # Use ActiveRecord::Serializable on this attribute if the
        # database does not support Hash conversions natively.
        self.serialized = true

        # Map over all models in the database and perform the given
        # query for their embedded items.
        def results
          @results ||= parent
                       .all
                       .map { |model| [model, query_for(model)] }
                       .select { |_model, items| items.any? }[from..to]
        end
      end
    end
  end
end
