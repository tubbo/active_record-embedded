module ActiveRecord
  module Embedded
    class Field::RegExp < Field
      # Convert regex into a hash of its pattern and options for
      # persistence.
      def cast(value)
        {
          '$pattern' => value.source,
          '$options' => value.options
        }
      end

      # Instantiate +Regexp+ object with +$pattern+ and +$options+ from
      # the hash value.
      def coerce(value)
        pattern = value['$pattern']
        options = value['$options']

        Regexp.new(pattern, options)
      end
    end
  end
end