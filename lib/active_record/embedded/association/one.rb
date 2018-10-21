# frozen_string_literal: true

module ActiveRecord
  module Embedded
    class Association
      # Represents a one-to-one association between an ActiveRecord
      # model and an +ActiveRecord::Embedded::Model+. Invoked by calling
      # +embeds_one+ on the parent model, it stores its data in the
      # database as a +Hash+, which is serialized by either ActiveRecord
      # or the database itself when persisted. As a result of this
      class One < self
        # Wrap the data stored in the one-to-one relationship as an
        # embedded model.
        #
        # @param [ActiveRecord::Base] model - Parent model
        # @return [ActiveRecord::Embedded::Model]
        def query(model)
          attributes = model[name]['data']
          return if attributes.nil?

          build(model, attributes)
        end

        # Since the +#query+ method takes care of building the resource,
        # ensure that the +#find+ method signature can still work.
        #
        # @param [ActiveRecord::Base] model - Parent model
        # @return [ActiveRecord::Embedded::Model]
        def find(model, _id = nil)
          query(model)
        end

        # Persist the given hash or model as embedded data on this
        # object.
        #
        # @param [ActiveRecord::Embedded::Model|Hash] embedded
        # @return [ActiveRecord::Embedded::Model]
        def assign(model, embedded)
          model[name] = { 'data': embedded.to_h }
          build(model, embedded)
        end
        alias update assign

        def create(model, params)
          build(model, params).tap(&:save)
        end

        def destroy(model, **_params)
          model[name]['data'] = nil
          model[name]['data'].blank?
        end

        def index(_model, _indexes, _data = [])
          true
        end
      end
    end
  end
end
