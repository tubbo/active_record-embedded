module ActiveRecord
  module Embedded
    module Model
      extend ActiveSupport::Concern

      include ActiveModel::Model

      included do
        class_attribute :embed, :fields, :associations
        self.fields ||= {}
        self.associations ||= {}
        field :id, default: -> { SecureRandom.uuid }
        attr_reader :_parent, :_association, :attributes
      end

      class_methods do
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

      def initialize(_parent: nil, _association: nil, **attributes)
        @_association = _association
        @_parent = _parent || attributes[self.embed.name]
        @attributes = attributes

        super(attributes)
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
        return false unless valid?
        assign_associated_attributes!
        _parent.save
      end

      def save!
        raise ActiveRecord::RecordNotSaved, errors unless valid?
        assign_associated_attributes!
        _parent.save!
      end

      def reload
        self.attributes = _attributes_from_database
        self
      end

      def inspect
        params = attributes.map { |key, val| "@#{key}=#{val}" }.join(' ')
        identifier = super.split(' ').first

        "#{identifier} #{params}>"
      end

      def assign_attributes(attrs = {})
        super cast_attributes(attrs)
      end

      private

      def assign_associated_attributes!
        self.id ||= SecureRandom.hex
        _association.update(_parent, attributes)
      end

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

      def _attributes_from_database
        _association.find(_parent, id).attributes
      end
    end
  end
end
