# frozen_string_literal: true

module ActiveRecord
  module Embedded
    class Field
      class Time < Field
        # Convert a +Time+ object to a numerical timestamp for persistence.
        def cast(value)
          value.to_i
        end

        # Construct a +Time+ object from a numerical timestamp for
        # rendering.
        def coerce(value)
          ::Time.at(value)
        end
      end
    end
  end
end
