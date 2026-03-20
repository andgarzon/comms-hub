class AddSlackChannelToContacts < ActiveRecord::Migration[7.1]
  def change
    add_column :contacts, :slack_channel, :string
  end
end
