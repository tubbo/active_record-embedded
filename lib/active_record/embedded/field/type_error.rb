module ActiveRecord
  module Embedded
    class Field
      class TypeError < ::TypeError
        def initialize(type)
          super "'#{type}' is not a valid type. Valid types are #{Field::TYPES}"
        end
      end
    end
  end
end
