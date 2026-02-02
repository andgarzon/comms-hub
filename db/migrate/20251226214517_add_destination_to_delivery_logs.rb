class AddDestinationToDeliveryLogs < ActiveRecord::Migration[8.1]
  def change
    add_column :delivery_logs, :destination, :string
  end
end
