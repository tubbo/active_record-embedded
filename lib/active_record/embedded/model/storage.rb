# frozen_string_literal: true

module ActiveRecord
  module Embedded
    module Model
      # Configure the parent model on the embedded model, using the
      # +embedded_in+ macro. Also provides functionality for setting the
      # parent model record and association for each individual embedded
      # model.
      module Storage
        extend ActiveSupport::Concern

        included do
          class_attribute :parent_model
          attr_reader :_parent, :_association
        end

        class_methods do
          # Configure the parent model alias on this embedded model.
          #
          # @param [Symbol] name - Name of the model (and method)
          # @param [Symbol] as - Configured name of the method
          # @param [String] class_name - Class name for the association
          def embedded_in(name, as: nil, **options)
            as = model_name.param_key.pluralize if as.nil?
            self.parent_model = Association::Parent.new(
              name: name, as: as, **options
            )
            define_method(name) { _parent }
          end
        end
      end
    end
  end
end
