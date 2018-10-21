# frozen_string_literal: true

module ActiveRecord
  module Embedded
    class Field
      # Store a regular expression pattern as an object field in the
      # database.
      class Regexp < Field
        def cast(value)
          return value if value.is_a? ::Hash

          {
            '$pattern' => value.source,
            '$options' => value.options
          }
        end

        # read from the database
        def coerce(value)
          return value if value.is_a? ::Regexp

          pattern = value['$pattern']
          options = value['$options']

          ::Regexp.new(pattern, options)
        end
      end
    end
  end
end
