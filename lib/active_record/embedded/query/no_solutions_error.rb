module ActiveRecord
  module Embedded
    module Query
      # Thrown when an index cannot be used on a query, and
      # +Embedded.scan_tables+ is set to +false+
      class NoSolutionsError < Error
      end
    end
  end
end
