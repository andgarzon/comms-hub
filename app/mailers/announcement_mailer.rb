class AnnouncementMailer < ApplicationMailer
  def broadcast(announcement_id, to:)
    @announcement = Announcement.find(announcement_id)
    
    mail(
      to: to,
      subject: @announcement.title,
      body: @announcement.email_body.presence || @announcement.base_body,
      content_type: "text/plain"
    )
  end
end
