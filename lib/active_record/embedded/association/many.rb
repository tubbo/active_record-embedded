module ActiveRecord
  module Embedded
    class Association
      # Represents a one-to-many association between an ActiveRecord
      # model and an ActiveRecord::Embedded::Model. Invoked by calling
      # +embeds_many+ on a parent model, and similar to a one-to-one
      # relationship, it stores its data on the model as a +Hash+, but
      # renders the data as an +Enumerable+ object that behaves
      # more like an array, or more accurately an
      # +ActiveRecord::Relation+.
      class Many < self
        # Query for finding models in a one-to-many relationship.
        #
        # @param [ActiveRecord::Base] model - parent model to find from.
        # @return [ActiveRecord::Embedded::Relation]
        def query(model)
          Relation.new(
            association: self,
            model: model
          )
        end

        # Return a given model by its ID.
        #
        # @param [ActiveRecord::Base] model - parent model to find from.
        # @param [String] id - ID of embedded record
        # @return [ActiveRecord::Embedded::Model] or +nil+ if not found.
        def find(model, id)
          query(model).find!(id)
        end

        # Mass-assign all records to the given data.
        #
        # @param [ActiveRecord::Base] model - parent model to save into.
        # @param [Enumerable] items - Parameters to save
        # @return [Hash] params saved into the parent model.
        def assign(model, items)
          model[name] ||= { 'data': [], 'index': {} }
          model[name]['data'] = items.map do |item|
            embedded = build(model, item.to_h)
            embedded.attributes
          end
          index(model)
        end

        # Update a single record in place.
        #
        # @param [ActiveRecord::Base] model - parent model to save into.
        # @param [Hash] item - Parameters to save
        # @return [Boolean] whether the operation succeeded
        def update(model, item)
          model[name] ||= { 'data': [], 'index': {} }
          model[name]['data'] << item.stringify_keys
          index(model)
        end

        # Destroy a single record in place.
        #
        # @param [ActiveRecord::Base] model - persistence model
        # @param [String] id - ID of element to destroy
        # @return [Boolean] whether the operation succeeded
        def destroy(model, id: )
          model[name] ||= { 'data': [], 'index': {} }
          model[name]['data'].reject! { |item| item['id'] == id }
          index(model)
        end

        # Reindex all data on this model.
        def index(model)
          data = model[name]['data']
          model[name]['index'] = indexes.each_with_object({}) do |index, json|
            json[index.name] = index.build(data)
          end
          true
        end
      end
    end
  end
end
