# frozen_string_literal: true

class AddAddressToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :address, :jsonb
  end
end
