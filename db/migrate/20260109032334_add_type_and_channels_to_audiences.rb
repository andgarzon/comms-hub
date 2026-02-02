class AddTypeAndChannelsToAudiences < ActiveRecord::Migration[8.1]
  def change
    add_column :audiences, :type, :string unless column_exists?(:audiences, :type)
    add_column :audiences, :whatsapp_recipients, :text unless column_exists?(:audiences, :whatsapp_recipients)
  end
end