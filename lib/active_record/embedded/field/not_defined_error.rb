# frozen_string_literal: true

module ActiveRecord
  module Embedded
    class Field
      # Thrown when an attempt is made to set an attribute on a model
      # that was not configured as a field.
      class NotDefinedError < Error
        def initialize(attribute)
          super "Field :#{attribute} is not defined."
        end
      end
    end
  end
end
