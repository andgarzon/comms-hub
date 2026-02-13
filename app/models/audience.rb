class Audience < ApplicationRecord
  SCOPE_TYPES = %w[personal role system].freeze

  belongs_to :creator, class_name: "User", foreign_key: :created_by_id, optional: true

  has_many :audience_memberships, dependent: :destroy
  has_many :announcement_audiences, dependent: :destroy
  has_many :announcements, through: :announcement_audiences
  has_many :users, through: :audience_memberships

  validates :name, presence: true
  validates :scope_type, inclusion: { in: SCOPE_TYPES }, allow_nil: true

  # Returns audiences visible to a given user
  scope :visible_to, ->(user) {
    if user.admin?
      all
    else
      where(scope_type: "system")
        .or(where(scope_type: "role", scope_value: user.role))
        .or(where(scope_type: "personal", created_by_id: user.id))
    end
  }

  scope :personal, -> { where(scope_type: "personal") }
  scope :for_role, ->(role) { where(scope_type: "role", scope_value: role) }
  scope :system_wide, -> { where(scope_type: "system") }

  def owned_by?(user)
    created_by_id == user.id
  end

  def editable_by?(user)
    return true if user.admin?
    owned_by?(user)
  end

  def email_list
    return [] if email_recipients.blank?
    email_recipients
      .split(/[\n,;]+/)
      .map(&:strip)
      .reject(&:blank?)
      .uniq
  end

  def recipients_count
    case type
    when "EmailAudience"
      email_list.size
    when "SlackAudience"
      1
    when "WhatsappAudience"
      whatsapp_list.size
    else
      users.count
    end
  end
end