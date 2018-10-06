class Order < ApplicationRecord
  embeds_many :items

  embeds_one :address
end
