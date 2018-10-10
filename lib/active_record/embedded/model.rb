module ActiveRecord
  module Embedded
    module Model
      extend ActiveSupport::Concern

      include ActiveModel::Model

      included do
        class_attribute :parent_model, :fields, :associations

        self.fields ||= {}
        self.associations ||= {}

        field :id, default: -> { SecureRandom.uuid }

        attr_reader :_parent, :_association, :attributes

        alias_method :reload!, :reload
      end

      class_methods do
        def embedded_in(name, as: nil, **options)
          as = model_name.param_key.pluralize if as.nil?
          self.parent_model = Association::Parent.new(name: name, as: as, **options)
          define_method(name) { _parent }
        end

        def field(name, type: String, default: nil)
          self.fields[name] = field = Field.find(type).new(name, default)
          define_method(name) { self[name] }
          define_method("#{name}=") { |value| self[name] = value }
        end

        def where(filters = {})
          Aggregation.create(
            model: self,
            filters: filters
          )
        end
      end

      def initialize(_parent: nil, _association: nil, **attributes)
        @_association = _association
        @_parent = _parent || attributes[parent_model.name]
        @attributes = attributes

        super(attributes)
      end

      # Read an attribute from the model.
      #
      # @param [Symbol] key - Attribute name
      def [](key)
        coerce key, attributes[key.to_sym]
      end

      # Write an attribute to the model.
      #
      # @param [Symbol] key - Attribute name
      # @param [Object] value - Value of this attribute
      def []=(key, value)
        attributes[key.to_sym] = cast(key, value)
      end

      # Whether this model exists in the database.
      def persisted?
        id.present?
      end

      # Whether this model does not exist in the database yet.
      def new_record?
        !persisted?
      end

      # Attempt to persist this model to the database.
      #
      # @return [Boolean]
      def save(validate: true)
        return false unless valid? if validate
        persist!
        _parent.save
      end

      # Attempt to persist this model to the database. Throw an error if
      # unsuccessful.
      #
      # @return [Boolean]
      # @throws [ActiveRecord::RecordNotSaved] if an error occurs
      def save!
        raise RecordNotSaved, errors unless valid?
        persist!
        _parent.save!
      end

      # Assign attributes to this model from the database, overwriting
      # what is stored in memory.
      #
      # @return [ActiveRecord::Embedded::Model] this object
      def reload
        self.attributes = _association.find(_parent, id).attributes
        self
      end

      # Cast attributes before assignment using +ActiveModel::AttributeMethods+.
      def assign_attributes(attrs = {})
        super cast_attributes(attrs)
      end

      def update(params = {})
        assign_attributes(params) and save
      end

      def update!(params = {})
        assign_attributes(params) and save!
      end

      def ==(other)
        return false if id.blank?
        id == other&.id
      end

      private

      # @private
      def persist!
        self.id ||= SecureRandom.hex
        _association.update(_parent, attributes)
      end

      # @private
      def cast_attributes(attrs = {})
        attrs.symbolize_keys.each_with_object({}) do |(attr, value), casted|
          casted[attr] = cast(attr, value)
        end
      end

      # @private
      def cast(attribute, value = nil)
        return if value.nil?
        field = self.class.fields[attribute]
        raise Field::NotDefinedError, attribute if field.blank?
        field.cast(value)
      end

      def coerce(attribute, value = nil)
        return if value.nil?
        field = self.class.fields[attribute.to_sym]
        raise Field::NotDefinedError, attribute if field.blank?
        field.coerce(value)
      end
    end
  end
end
