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

        def update(model, items)
          model[name] = items.each_with_object({}) do |item, data|
            embedded = build(model, item)
            data[embedded.id] = embedded.attributes
          end
        end
      end
    end
  end
end
