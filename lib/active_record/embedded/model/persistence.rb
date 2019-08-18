# frozen_string_literal: true

module ActiveRecord
  module Embedded
    module Model
      # Functionality for persisting an embedded model's data into the
      # database. Includes basic CRUD methods and defines the callback
      # lifecycle for +Embedded::Model+.
      module Persistence
        extend ActiveSupport::Concern

        included do
          define_model_callbacks :validation, :save, :create,
                                 :update, :destroy, :initialize

          alias_method :reload!, :reload
        end

        # Run validations on this model.
        #
        # @return [Boolean] whether any errors occurred
        def valid?(*)
          run_callbacks(:validation) { super }
        end

        # Attempt to persist this model to the database.
        #
        # @return [Boolean] whether the operation succeeded
        def save(validate: true)
          return false if validate && !valid?

          run_callbacks :save do
            persist! && _parent.save
          end
        end

        # Attempt to persist this model to the database. Throw an error if
        # unsuccessful.
        #
        # @return [TrueClass] if the operation succeeded
        # @throws [ActiveRecord::RecordNotSaved] if an error occurs
        def save!
          raise RecordNotSaved, errors.full_messages.to_sentence unless valid?

          run_callbacks :save do
            persist! && _parent.save!
          end
        end

        # Mass-assign parameters to the data on this model.
        #
        # @return [Boolean] whether the operation succeeded
        def update(params = {})
          valid? && assign_attributes(params) && save
        end

        # Mass-assign parameters to the data on this model. Throw an error
        # if it does not succeed.
        #
        # @return [TrueClass] if the operation succeeded
        # @throws [ActiveRecord::RecordNotSaved] if an error occurs
        def update!(params = {})
          raise RecordNotValid, errors.full_messages.to_sentence unless valid?

          assign_attributes(params) && save!
        end

        # Delete this model from its parent and the database.
        #
        # @return [Boolean] whether the operation succeeded
        def destroy
          run_callbacks :destroy do
            _association.destroy(_parent, id: id) && _parent.save
          end
        end

        # Delete this model. Throw an error if unsuccessful.
        #
        # @return [TrueClass] if the operation succeeded
        # @throws [ActiveRecord::RecordNotDestroyed] if an error occurs
        def destroy!
          destroy || raise(RecordNotDestroyed, self)
        end

        # Whether this model exists in the database.
        #
        # @return [Boolean] whether an +:id+ exists on this model
        def persisted?
          attributes[:id].present?
        end

        # Whether this model does not exist in the database yet.
        #
        # @return [Boolean] whether +#persisted?+ is +false+
        def new_record?
          !persisted?
        end

        # Assign attributes to this model from the database, overwriting
        # what is stored in memory.
        #
        # @return [ActiveRecord::Embedded::Model] this object
        def reload
          raise RecordNotFound unless persisted?

          self.attributes = _association.find(_parent, id).attributes
          self
        end

        private

        # @private
        def persist!
          _create || _update
        end

        # @private
        def _create
          return false unless new_record?

          self.id = SecureRandom.uuid

          run_callbacks :create do
            _association.update(_parent, attributes)
          end
        end

        # @private
        def _update
          return false unless persisted?

          self.updated_at = Time.current

          run_callbacks :update do
            _association.update(_parent, attributes)
          end
        end
      end
    end
  end
end
