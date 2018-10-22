# frozen_string_literal: true

module ActiveRecord
  module Embedded
    # Describes "base class" functionality.
    module Interface
      # All type names, which are subclasses of this object.
      #
      # @return [Array<String>]
      def types
        subclasses.map { |subclass| subclass.name.gsub(prefix, '') }
      end

      # Find a class that implements this interface by the given slug.
      def find(slug)
        type = slug.to_s.demodulize.classify

        subclasses.find do |subclass|
          subclass.name.gsub(prefix, '') == type.to_s.gsub(prefix, '')
        end || raise(TypeError.new(type, types.to_sentence))
      end

      # Instantiate a new class that implements this interface.
      def create(type:, **options)
        find(type).new(**options)
      end

      private

      # Module prefix for all implementations of this interface.
      #
      # @private
      def prefix
        "#{name}::"
      end
    end
  end
end
