# frozen_string_literal: true

module ActiveRecord
  module Embedded
    class Field
      class Array < self
        def cast(value)
          value.to_a
        end
      end
    end
  end
end
