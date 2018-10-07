module ActiveRecord
  module Embedded
    class Field
      TYPES = %w(String Integer Float Hash Array)

      attr_reader :name, :type, :default

      def initialize(name: , type: String, default: nil)
        @name = name
        @type = type
        @default = default
      end

      def cast(value)
        case type.name
        when 'String'
          value.to_s
        when 'Integer'
          value.to_i
        when 'Float'
          value.to_f
        when 'Hash'
          value.to_h
        when 'Array'
          value.to_a
        else
          raise TypeError, type
        end
      end
    end
  end
end
