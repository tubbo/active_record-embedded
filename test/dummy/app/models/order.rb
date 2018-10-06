class Order < ApplicationRecord
  embeds_many :items
end
