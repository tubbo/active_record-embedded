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
          model[name] = items.each_with_object({}) do |item, data|
            embedded = build(model, item.to_h)
            data[embedded.id] = embedded.attributes
          end
        end

        # Update a single record in place.
        #
        # @param [ActiveRecord::Base] model - parent model to save into.
        # @param [Hash] item - Parameters to save
        # @return [Hash] params saved into the parent model.
        def update(model, item)
          model[name] ||= {}
          params = item.symbolize_keys
          id = params[:id]

          model[name][id] = params
        end
      end
    end
  end
end
