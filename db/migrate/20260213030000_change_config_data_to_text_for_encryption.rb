class ChangeConfigDataToTextForEncryption < ActiveRecord::Migration[8.1]
  def up
    # Convert jsonb to text so Rails encryption can work on it
    # First, read any existing data
    change_column :integration_settings, :config_data, :text
  end

  def down
    change_column :integration_settings, :config_data, :jsonb, default: {}
  end
end
