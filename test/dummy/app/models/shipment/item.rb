class Shipment::Item
  include ActiveRecord::Embedded::Model

  embedded_in :shipment

  field :sku
  field :quantity, type: Integer
  field :shipping_price, type: Float
end
