class CreateShipments < ActiveRecord::Migration[5.2]
  def change
    create_table :shipments do |t|
      t.references :order
      t.json :items

      t.timestamps
    end
  end
end
