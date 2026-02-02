class AddChannelBodiesToAnnouncements < ActiveRecord::Migration[8.1]
  def change
    add_column :announcements, :base_body, :text
    add_column :announcements, :email_body, :text
    add_column :announcements, :slack_body, :text
    add_column :announcements, :whatsapp_body, :text
  end
end
