# frozen_string_literal: true

module ActiveRecord
  module Embedded
    class Field
      # Thrown when a configured field type cannot be handled as JSON.
      class TypeError < Error
        def initialize(klass)
          type = klass.to_s.demodulize
          types = Field.types.to_sentence
          super "'#{type}' is not a valid type. Valid types are #{types}."
        end
      end
    end
  end
end
