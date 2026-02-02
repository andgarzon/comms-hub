class CreateAnnouncementTargets < ActiveRecord::Migration[8.1]
  def change
    create_table :announcement_targets do |t|
      t.references :announcement, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true

      t.timestamps
    end
  end
end
