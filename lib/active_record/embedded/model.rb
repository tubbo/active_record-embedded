module ActiveRecord
  module Embedded
    class Model
      include ActiveModel::Model

      class_attribute :embed, :fields, :associations
      self.fields ||= {}
      self.associations ||= {}

      class << self
        def embedded_in(name)
          self.embed = Association::Parent.new(name: name)
          define_method(name) { _parent }
        end

        def field(name, **options)
          self.fields[name] = field = Field.new(name: name, **options)
          define_method(name) { field.cast(self[name]) }
          define_method("#{name}=") { |value| self[name] = field.cast(value) }
        end
      end

      field :id, default: -> { SecureRandom.uuid }

      attr_reader :_parent, :_association, :attributes

      def initialize(_parent: nil, _association: nil, **attributes)
        @_association = _association
        @_parent = _parent || attributes[self.embed.name]
        @attributes = cast_attributes(attributes)

        super(attributes)
      end

      def attributes=(params = {})
        super cast_attributes(params)
      end

      def [](key)
        attributes[key.to_sym]
      end

      def []=(key, value)
        attributes[key.to_sym] = cast(key, value)
      end

      def persisted?
        id.present?
      end

      def save
        _association.update(_parent, attributes)
        _parent.save
      end

      def reload
        self.attributes = _association.find(_parent)
        self
      end

      private

      def cast_attributes(attrs = {})
        attrs.symbolize_keys.each_with_object({}) do |(attr, value), casted|
          casted[attr] = cast(attr, value)
        end
      end

      def cast(attribute, value)
        field = self.class.fields[attribute]
        raise Field::NotDefinedError.new(attribute, self.class.name) if field.blank?
        self.class.fields[attribute].cast(value)
      end
    end
  end
end
