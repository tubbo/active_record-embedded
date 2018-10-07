module ActiveRecord
  module Embedded
    class Association
      class One < self
        def find(model)
          build model, model[name]
        end

        def update(model, embedded)
          model[name] = embedded
          find(model)
        end
      end
    end
  end
end