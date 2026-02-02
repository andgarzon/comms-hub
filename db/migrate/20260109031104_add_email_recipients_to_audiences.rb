class AddEmailRecipientsToAudiences < ActiveRecord::Migration[8.1]
  def change
    add_column :audiences, :email_recipients, :text
  end
end
