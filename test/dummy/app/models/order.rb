# frozen_string_literal: true

class Order < ApplicationRecord
  embeds_many :items

  embeds_one :address
  embeds_one :customizations, class_name: 'Order::Customizations'
end
