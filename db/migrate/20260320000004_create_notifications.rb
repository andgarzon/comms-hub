class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :announcement, null: false, foreign_key: true
      t.string :event, null: false
      t.text :summary, null: false
      t.boolean :read, default: false, null: false
      t.timestamps
    end

    add_index :notifications, [:user_id, :read]
  end
end
