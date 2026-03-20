class RemoveEmployeeContactType < ActiveRecord::Migration[7.1]
  def up
    Contact.where(contact_type: "employee").update_all(contact_type: "admin_staff")
    change_column_default :contacts, :contact_type, "admin_staff"
  end

  def down
    change_column_default :contacts, :contact_type, "employee"
  end
end
