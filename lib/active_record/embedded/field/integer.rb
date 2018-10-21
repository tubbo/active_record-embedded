# frozen_string_literal: true

module ActiveRecord
  module Embedded
    class Field
      class Integer < self
        def cast(value)
          value.to_i
        end
      end
    end
  end
end
