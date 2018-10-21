module ActiveRecord
  module Embedded
    class Field
      class NotDefinedError < Error
        def initialize(attribute)
          super "Field :#{attribute} is not defined."
        end
      end
    end
  end
end
