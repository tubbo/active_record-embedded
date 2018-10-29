class Fulfillment < ApplicationRecord
  establish_connection(
    adapter: 'sqlserver',
    username: 'root',
    database: 'active_record_embedded_test'
  )

  include ActiveRecord::Embedded

  belongs_to :order

  embeds_many :packages, class_name: 'Fulfillment::Package'
end
