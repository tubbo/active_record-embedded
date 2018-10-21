# frozen_string_literal: true

module ActiveRecord
  module Embedded
    class Field
      # A JSON "object" type is converted to Ruby as a native Hash with
      # string keys.
      class Hash < self
        def cast(value)
          value.to_h
        end
      end
    end
  end
end
