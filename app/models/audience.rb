class Audience < ApplicationRecord
  has_many :audience_memberships, dependent: :destroy
  has_many :announcement_audiences, dependent: :destroy
  has_many :announcements, through: :announcement_audiences
  has_many :users, through: :audience_memberships

  validates :name, presence: true

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