# frozen_string_literal: true

module ActiveRecord
  module Embedded
    class Association
      # Parent associations are a "reverse" association defined on the
      # embedded model, which reference the parent model in an
      # easy-to-use way.
      class Parent < self
        attr_reader :as

        def association
          embedded_class.embeds[as.to_sym]
        end
      end
    end
  end
end
