# frozen_string_literal: true

class Item
  include ActiveRecord::Embedded::Model

  embedded_in :order

  field :sku
  field :quantity, type: Integer
  field :price, type: Float, default: 0.0
  field :customizations, type: Hash, default: {}
  field :discounts, type: Array, default: []
  field :placed_at, type: Time
  field :product_attributes, type: Hash, default: {}
  field :price_adjustments, type: Array, default: []

  validates :quantity, presence: true

  attr_accessor :should_calculate_price

  before_create :ensure_price, if: :should_calculate_price

  index %i[sku], direction: :asc

  private

  def ensure_price
    self.price = Random.rand(20..30) + 0.99
  end
end
