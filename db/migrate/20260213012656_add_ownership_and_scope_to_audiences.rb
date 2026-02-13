class AddOwnershipAndScopeToAudiences < ActiveRecord::Migration[8.1]
  def change
    add_reference :audiences, :created_by, foreign_key: { to_table: :users }, null: true
    add_column :audiences, :scope_type, :string, default: "personal"
    add_column :audiences, :scope_value, :string
    add_index :audiences, :scope_type
    add_index :audiences, :scope_value
  end
end
