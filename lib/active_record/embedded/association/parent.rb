module ActiveRecord
  module Embedded
    class Association
      class Parent < self
        attr_reader :as

        def association
          embedded_class.embeds[as.to_sym]
        end
      end
    end
  end
end
