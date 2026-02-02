class CreateAnnouncementAudiences < ActiveRecord::Migration[8.1]
  def change
    create_table :announcement_audiences do |t|
      t.references :announcement, null: false, foreign_key: true
      t.references :audience, null: false, foreign_key: true

      t.timestamps
    end
  end
end
