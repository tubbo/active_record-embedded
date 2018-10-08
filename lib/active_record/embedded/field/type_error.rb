module ActiveRecord
  module Embedded
    class Field
      class TypeError < ::TypeError
        def initialize(klass)
          type = klass.to_s.demodulize
          types = Field.types.to_sentence
          super "'#{type}' is not a valid type. Valid types are #{types}."
        end
      end
    end
  end
end
