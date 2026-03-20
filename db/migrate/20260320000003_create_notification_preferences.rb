class CreateNotificationPreferences < ActiveRecord::Migration[8.0]
  def change
    create_table :notification_preferences do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.boolean :email_on_sent, default: true, null: false
      t.boolean :email_on_failure, default: true, null: false
      t.boolean :in_app_on_sent, default: true, null: false
      t.boolean :in_app_on_failure, default: true, null: false
      t.timestamps
    end
  end
end
