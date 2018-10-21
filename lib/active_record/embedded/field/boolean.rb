# frozen_string_literal: true

module ActiveRecord
  module Embedded
    class Field
      # In Ruby, boolean values are represented as the singletons +true+
      # and +false+, which are instances of +TrueClass+ and
      # +FalseClass+, respectively. JSON has no such distinction,
      # boolean values can be either value or +null+.
      class Boolean < self
        def cast(value)
          !!value
        end
      end
    end
  end
end
