class CreateFulfillments < ActiveRecord::Migration[5.2]
  def change
    create_table :fulfillments do |t|
      t.references :order, foreign_key: true
      t.string :status

      t.timestamps
    end
  end
end
