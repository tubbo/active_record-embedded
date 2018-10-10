class Item
  include ActiveRecord::Embedded::Model

  embedded_in :order

  field :sku
  field :quantity, type: Integer
  field :price, type: Float, default: 0.0
  field :customizations, type: Hash, default: {}
  field :discounts, type: Array, default: []
  field :placed_at, type: Time

  validates :quantity, presence: true
end
