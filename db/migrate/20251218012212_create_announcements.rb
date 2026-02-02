class CreateAnnouncements < ActiveRecord::Migration[8.1]
  def change
    create_table :announcements do |t|
      t.string :title
      t.text :body
      t.references :user, null: false, foreign_key: true
      t.boolean :send_to_slack
      t.boolean :send_to_email
      t.boolean :send_to_whatsapp

      t.timestamps
    end
  end
end
