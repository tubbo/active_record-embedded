class Item < ActiveRecord::Embedded::Model
  field :sku
  field :quantity, type: Integer
end
