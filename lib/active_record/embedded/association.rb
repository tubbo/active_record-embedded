module ActiveRecord
  module Embedded
    class Association
      attr_reader :name, :class_name

      delegate :indexes, to: :embedded_class

      def initialize(name: , class_name: nil, **options)
        @name = name
        @class_name = class_name || name.to_s.classify
        options.each { |key, value| instance_variable_set "@#{key}", value }
      end

      def query(model)
        raise NotImplementedError, "#{self.class.name}#find"
      end

      def find(model, id)
        raise NotImplementedError, "#{self.class.name}#find"
      end

      def assign(model, params)
        raise NotImplementedError, "#{self.class.name}#find"
      end

      def create(model, params)
        raise NotImplementedError, "#{self.class.name}#create"
      end

      def update(model, params)
        raise NotImplementedError, "#{self.class.name}#update"
      end

      def destroy(model, **params)
        raise NotImplementedError, "#{self.class.name}#destroy"
      end

      def index(model, data = [])
        raise NotImplementedError, "#{self.class.name}#index"
      end

      def build(model, value = {})
        return value if value.is_a? embedded_class
        embedded_class.new(_parent: model, _association: self, **value.symbolize_keys)
      end

      def embedded_class
        class_name.constantize
      end
    end
  end
end
