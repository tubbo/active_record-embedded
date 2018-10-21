# frozen_string_literal: true

module ActiveRecord
  module Embedded
    class Field
      class String < self
        def cast(value)
          value.to_s
        end
      end
    end
  end
end
