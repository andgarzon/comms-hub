class CreateDeliveryLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :delivery_logs do |t|
      t.references :announcement, null: false, foreign_key: true
      t.string :channel
      t.string :status
      t.text :details

      t.timestamps
    end
  end
end
