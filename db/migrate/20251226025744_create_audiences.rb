class CreateAudiences < ActiveRecord::Migration[8.1]
  def change
    create_table :audiences do |t|
      t.string :name
      t.string :description
      t.string :slack_channel

      t.timestamps
    end
  end
end
