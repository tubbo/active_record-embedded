# frozen_string_literal: true

module ActiveRecord
  module Embedded
    # Thrown when a configured field type cannot be handled as JSON.
    class TypeError < Error
      def initialize(type, types)
        super "'#{type}' is not a valid type. Valid types are #{types}."
      end
    end
  end
end
