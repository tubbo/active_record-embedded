class AddCustomizationsToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :customizations, :jsonb
  end
end
