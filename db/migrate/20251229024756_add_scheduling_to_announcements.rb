class AddSchedulingToAnnouncements < ActiveRecord::Migration[8.1]
  def change
    add_column :announcements, :scheduled_for, :datetime
    add_column :announcements, :status, :string
  end
end
