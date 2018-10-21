# frozen_string_literal: true

module ActiveRecord
  module Embedded
    class Field
      # Convert the value of the field this represents into a String for
      # JSON.
      class String < self
        def cast(value)
          value.to_s
        end
      end
    end
  end
end
