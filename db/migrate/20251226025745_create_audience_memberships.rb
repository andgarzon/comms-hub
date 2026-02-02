class CreateAudienceMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :audience_memberships do |t|
      t.references :audience, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
