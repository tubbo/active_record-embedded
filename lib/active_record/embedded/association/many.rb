module ActiveRecord
  module Embedded
    class Association
      class Many < self
        def find(model)
          Relation.new(
            association: self,
            model: model
          )
        end

        def get(model, id)
          find(model).find(id)
        end

        def assign(model, items)
          model[name] = items.each_with_object({}) do |item, data|
            embedded = build(model, item.to_h)
            data[embedded.id] = embedded.attributes
          end
        end

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
