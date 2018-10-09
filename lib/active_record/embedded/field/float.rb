module ActiveRecord
  module Embedded
    class Field
      class Float < self
        def cast(value)
          value.to_f
        end
      end
    end
  end
end
