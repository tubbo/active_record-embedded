# frozen_string_literal: true

module ActiveRecord
  module Embedded
    class Field
      class Boolean < self
        def cast(value)
          !!value
        end
      end
    end
  end
end
