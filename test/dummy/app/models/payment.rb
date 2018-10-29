# Test model for SQLite3
class Payment < ApplicationRecord
  include ActiveRecord::Embedded

  establish_connection(
    adapter: 'sqlite3',
    database: 'db/active_record_embedded_test.sqlite3'
  )

  belongs_to :order

  embeds_one :tender, class_name: 'Payment::Tender'
end
