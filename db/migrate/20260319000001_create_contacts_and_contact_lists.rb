class CreateContactsAndContactLists < ActiveRecord::Migration[8.1]
  def change
    create_table :contact_lists do |t|
      t.string :name, null: false
      t.text :description
      t.string :company
      t.string :list_type
      t.jsonb :import_metadata, default: {}
      t.timestamps
    end

    create_table :contacts do |t|
      t.string :name, null: false
      t.string :email
      t.string :phone_number
      t.string :slack_username
      t.string :company
      t.string :department
      t.string :contact_type, default: "employee"
      t.boolean :active, default: true, null: false
      t.references :contact_list, foreign_key: true
      t.timestamps
    end

    add_index :contacts, [:email, :company], unique: true, where: "email IS NOT NULL AND email != ''"

    create_table :audience_contacts do |t|
      t.references :audience, null: false, foreign_key: true
      t.references :contact, null: false, foreign_key: true
      t.timestamps
    end

    add_index :audience_contacts, [:audience_id, :contact_id], unique: true
  end
end
