# frozen_string_literal: true

module ActiveRecord
  module Embedded
    # Base class for all embedded associations, such as +embeds_one+ and
    # +embeds_many+. Defines the interface that such associations must
    # implement in order to be compatible with the rest of the
    # +ActiveRecord::Embedded+ API.
    class Association
      attr_reader :name, :class_name

      delegate :indexes, to: :embedded_class

      def initialize(name:, class_name: nil, **options)
        @name = name
        @class_name = class_name || name.to_s.classify
        options.each { |key, value| instance_variable_set "@#{key}", value }
      end

      def query(_model)
        raise NotImplementedError, "#{self.class.name}#find"
      end

      def find(_model, _id)
        raise NotImplementedError, "#{self.class.name}#find"
      end

      def assign(_model, _params)
        raise NotImplementedError, "#{self.class.name}#find"
      end

      def create(_model, _params)
        raise NotImplementedError, "#{self.class.name}#create"
      end

      def update(_model, _params)
        raise NotImplementedError, "#{self.class.name}#update"
      end

      def destroy(_model, **_params)
        raise NotImplementedError, "#{self.class.name}#destroy"
      end

      def index(_model, _data = [])
        raise NotImplementedError, "#{self.class.name}#index"
      end

      def build(model, value = {})
        return value if value.is_a? embedded_class

        embedded_class.new(
          _parent: model,
          _association: self,
          **value.symbolize_keys
        )
      end

      def embedded_class
        class_name.constantize
      end
    end
  end
end
