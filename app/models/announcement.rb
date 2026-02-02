class Announcement < ApplicationRecord
  belongs_to :user
  has_many :delivery_logs, dependent: :destroy
  has_many :announcement_targets, dependent: :destroy
  has_many :groups, through: :announcement_targets
  

  has_many :announcement_audiences, dependent: :destroy
  has_many :audiences, through: :announcement_audiences
  
  validates :title, :base_body, presence: true

  validates :status, inclusion: { in: %w[draft scheduled sending sent failed], allow_nil: true }


  validate :scheduled_for_must_be_in_future_if_pending


  def scheduled?
    scheduled_for.present? && scheduled_for.future?
  end

   private

def scheduled_for_must_be_in_future_if_pending
  return if scheduled_for.blank?

  # Only enforce future scheduling while it's not yet sent.
  pending_statuses = [nil, "", "draft", "scheduled"]
  return unless pending_statuses.include?(status)

  errors.add(:scheduled_for, "must be in the future") unless scheduled_for.future?
end



end
