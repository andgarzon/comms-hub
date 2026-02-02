class WhatsappAudience < Audience
  validates :name, presence: true

  def whatsapp_list
    return [] if whatsapp_recipients.blank?
    whatsapp_recipients.split(/[\n,;]+/).map(&:strip).reject(&:blank?).uniq
  end
end
