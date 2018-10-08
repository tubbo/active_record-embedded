module ActiveRecord
  module Embedded
    class Field
      class NotDefinedError < StandardError
        def initialize(attribute)
          super "Field :#{attribute} is not defined."
        end
      end
    end
  end
end
