# frozen_string_literal: true

module ActiveRecord
  module Embedded
    # Mixin for embedded models.
    module Model
      extend ActiveSupport::Concern

      include ActiveModel::Model

      included do
        class_attribute :parent_model, :fields, :associations, :indexes

        self.fields ||= {}
        self.associations ||= {}
        self.indexes = Index::Collection.new

        field :id, default: -> { SecureRandom.uuid }
        field :created_at, type: Time, default: -> { Time.current }
        field :updated_at, type: Time, default: -> { Time.current }

        index :id, unique: true

        attr_reader :_parent, :_association, :attributes

        alias_method :reload!, :reload
        alias_method :has_attribute?, :key?
        alias_method :read_attribute, :[]
        alias_method :write_attribute, :[]=

        define_model_callbacks :validation, :save, :create,
                               :update, :destroy, :initialize
      end

      class_methods do
        delegate_missing_to :aggregate

        def embedded_in(name, as: nil, **options)
          as = model_name.param_key.pluralize if as.nil?
          self.parent_model = Association::Parent.new(
            name: name, as: as, **options
          )
          define_method(name) { _parent }
        end

        # Define an embedded field.
        #
        # @param [Symbol] name - Name of the field
        # @param [Class] type - Class of the field type
        # @param [Object|Proc] default (optional) - Default value
        def field(name, type: String, default: nil)
          self.fields[name] = field = Field.find(type).new(name, default)
          define_method(name) { self[name] }
          define_method("#{name}=") { |value| self[name] = value }
          return unless field.default?

          define_method(field.default_method_name, field.default)
        end

        # Create a new index on this model.
        #
        # @param [Array] attributes
        # @param [Hash] options
        def index(attributes, **options)
          indexes << Index.new(attributes: attributes, **options)
        end

        # Filter items by a given set of parameters, in the form of
        # +:key => "value"+.
        #
        # @param [Hash] filters - Filtering options
        # @return [ActiveRecord::Embedded::Aggregation] Query Object
        def where(filters = {})
          aggregate(where: filters)
        end

        # Sort items by a given set of parameters, in the form of
        # +:attribute => :direction+.
        #
        # @example Sort user addresses by creation date
        #   User::Address.order(created_at: :asc)
        # @param [Hash] sorts - Sorting options
        # @return [ActiveRecord::Embedded::Aggregation] Query Object
        def order(sorts = {})
          aggregate(order: sorts)
        end

        # Define a new aggregation query.
        #
        # @param [Hash] where - Filtering options
        # @param [Hash] order - Sorting options
        # @return [ActiveRecord::Embedded::Aggregation] Query Object
        def aggregate(where: {}, order: {})
          association = parent_model&.association

          Aggregation.create(
            model: self,
            filters: where,
            sorts: order,
            association: association
          )
        end

        def field_names
          fields.keys
        end
      end

      def initialize(_parent: nil, _association: nil, **attributes)
        @_parent = _parent || attributes[parent_model.name]
        @_association = _association
        @attributes = attributes

        run_callbacks :initialize do
          super(attributes)
        end
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

      # Whether the given attribute exists on this model.
      def key?(key)
        attributes.key?(key.to_sym)
      end

      # Whether this model exists in the database.
      def persisted?
        attributes[:id].present?
      end

      # Whether this model does not exist in the database yet.
      def new_record?
        !persisted?
      end

      # Run validations on this model.
      #
      # @return [Boolean] whether any errors occurred
      def valid?(*)
        run_callbacks(:validation) { super }
      end

      # Attempt to persist this model to the database.
      #
      # @return [Boolean]
      def save(validate: true)
        return false if validate && !valid?

        run_callbacks :save do
          persist! && _parent.save
        end
      end

      # Attempt to persist this model to the database. Throw an error if
      # unsuccessful.
      #
      # @return [Boolean]
      # @throws [ActiveRecord::RecordNotSaved] if an error occurs
      def save!
        raise RecordNotSaved, errors unless valid?

        run_callbacks :save do
          persist! && _parent.save!
        end
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

      # Mass-assign parameters to the data on this model.
      def update(params = {})
        valid? && assign_attributes(params) && save
      end

      # Mass-assign parameters to the data on this model. Throw an error
      # if it does not succeed.
      def update!(params = {})
        raise RecordNotValid, errors unless valid?

        assign_attributes(params) && save!
      end

      # Delete this model.
      def destroy
        run_callbacks :destroy do
          _association.destroy(_parent, id: id) && _parent.save
        end
      end

      # Delete this model. Throw an error if unsuccessful.
      def destroy!
        destroy || raise(RecordNotDestroyed, self)
      end

      # Another record is equal to this model if its +#id+ is the same.
      #
      # @return [Boolean] whether both models' IDs are equal
      def ==(other)
        return false if id.blank?

        id == other&.id
      end

      def inspect
        inspection = if @attributes
                       self.class.field_names.collect do |name|
                         if has_attribute?(name)
                           "#{name}: #{attribute_for_inspect(name)}"
                         end
                       end.compact.join(', ')
                     else
                       'not initialized'
                     end
        "#<#{self.class} #{inspection}>"
      end

      private

      def attribute_for_inspect(attr_name)
        value = read_attribute(attr_name)

        if value.is_a?(String) && value.length > 50
          "#{value[0, 50]}...".inspect
        elsif value.is_a?(Date) || value.is_a?(Time)
          %("#{value.to_s(:db)}")
        else
          value.inspect
        end
      end

      # @private
      def persist!
        _create || _update
      end

      def _create
        return false unless new_record?

        self.id = SecureRandom.uuid

        run_callbacks :create do
          _association.update(_parent, attributes)
        end
      end

      def _update
        return false unless persisted?

        self.updated_at = Time.current

        run_callbacks :update do
          _association.update(_parent, attributes)
        end
      end

      # @private
      def cast_attributes(attrs = {})
        attrs.symbolize_keys.each_with_object({}) do |(attr, value), casted|
          casted[attr] = cast(attr, value)
        end
      end

      # @private
      def cast(attribute, value = nil)
        field = self.class.fields[attribute]
        raise Field::NotDefinedError, attribute if field.blank?

        casted_value = field.cast(value) unless value.blank?
        return public_send(field.default_method_name) if casted_value.blank?

        casted_value
      end

      def coerce(attribute, value = nil)
        field = self.class.fields[attribute.to_sym]
        raise Field::NotDefinedError, attribute if field.blank?

        coerced_value = field.coerce(value) unless value.blank?
        return public_send(field.default_method_name) if coerced_value.blank?

        coerced_value
      end
    end
  end
end
