# frozen_string_literal: true

# Test model using MySQL
class Shipment < ApplicationRecord
  establish_connection(
    YAML.load_file(
      Rails.root.join('config', 'database_mysql.yml')
    )[Rails.env].with_indifferent_access
  )

  include ActiveRecord::Embedded

  belongs_to :order

  embeds_many :items, class_name: 'Shipment::Item'
end
