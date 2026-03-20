class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :announcement

  scope :unread, -> { where(read: false) }
  scope :recent, -> { order(created_at: :desc).limit(20) }

  def mark_read!
    update!(read: true)
  end
end
