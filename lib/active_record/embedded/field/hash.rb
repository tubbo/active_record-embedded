module ActiveRecord
  module Embedded
    class Field
      class Hash < self
        def cast(value)
          value.to_h
        end
      end
    end
  end
end
