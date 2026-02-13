class Announcement < ApplicationRecord
  STATUSES = %w[draft scheduled sending sent failed].freeze

  belongs_to :user
  has_many :delivery_logs, dependent: :destroy
  has_many :announcement_targets, dependent: :destroy
  has_many :groups, through: :announcement_targets

  has_many :announcement_audiences, dependent: :destroy
  has_many :audiences, through: :announcement_audiences

  validates :title, :base_body, presence: true
  validates :status, inclusion: { in: STATUSES, allow_nil: true }

  validate :scheduled_for_must_be_in_future_if_pending

  # Status scopes
  scope :drafts, -> { where(status: "draft") }
  scope :scheduled_items, -> { where(status: "scheduled") }
  scope :sent_items, -> { where(status: "sent") }
  scope :failed_items, -> { where(status: "failed") }
  scope :sending_items, -> { where(status: "sending") }

  scope :by_status, ->(status) {
    case status.to_s
    when "draft" then drafts
    when "scheduled" then scheduled_items
    when "sent" then sent_items
    when "failed" then failed_items
    when "sending" then sending_items
    else all
    end
  }

  def scheduled?
    scheduled_for.present? && scheduled_for.future?
  end

  def draft?
    status == "draft"
  end

  def sent_status?
    status == "sent"
  end

  def failed?
    status == "failed"
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
