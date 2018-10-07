module ActiveRecord
  module Embedded
    class Field
      class NotDefinedError < StandardError
        def initialize(attribute, model)
          super "Field :#{attribute} not defined on #{model}"
        end
      end
    end
  end
end
