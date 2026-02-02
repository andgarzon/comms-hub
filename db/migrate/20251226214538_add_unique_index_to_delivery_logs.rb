class AddUniqueIndexToDeliveryLogs < ActiveRecord::Migration[8.1]
  def change
    add_index :delivery_logs, [:announcement_id, :channel, :destination], unique: true

  end
end
