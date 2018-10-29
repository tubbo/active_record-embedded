class Fulfillment::Package
  include ActiveRecord::Embedded::Model

  field :tracking_number
  field :sku
  field :quantity
end
