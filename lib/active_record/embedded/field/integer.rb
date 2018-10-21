# frozen_string_literal: true

module ActiveRecord
  module Embedded
    class Field
      # Store whole numbers in the database. JSON has no
      # distinction between integers and floats, but since Ruby does,
      # this class ensures that the field can always be used as the
      # "right" type.
      class Integer < self
        def cast(value)
          value.to_i
        end
      end
    end
  end
end
