# frozen_string_literal: true

module ActiveRecord
  module Embedded
    class Field
      # Convert the value of the field this represents into a String for
      # JSON, but convert it back to a Symbol when it comes back out of
      # the database.
      class Symbol < self
        def cast(value)
          value.to_s
        end

        def coerce(value)
          value.to_sym
        end
      end
    end
  end
end
