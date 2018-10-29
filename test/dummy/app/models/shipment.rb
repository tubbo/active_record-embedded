# Test model using MySQL
class Shipment < ApplicationRecord
  include ActiveRecord::Embedded

  establish_connection(
    adapter: 'mysql2',
    username: 'root',
    database: 'active_record_embedded_test'
  )

  belongs_to :order

  embeds_many :items, class_name: 'Shipment::Item'
end
