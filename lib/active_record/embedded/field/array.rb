# frozen_string_literal: true

module ActiveRecord
  module Embedded
    class Field
      # Store an +Array+ in the database as a JSON Array. Much like
      # +Field::Hash+, the JSON library in Ruby is used to encode this
      # value (and the values within it) to JSON.
      class Array < self
        def cast(value)
          value.to_a
        end
      end
    end
  end
end
