class EmailAudience < Audience
  validates :name, presence: true

  def email_list
    return [] if email_recipients.blank?
    email_recipients.split(/[\n,;]+/).map(&:strip).reject(&:blank?).uniq
  end
end
