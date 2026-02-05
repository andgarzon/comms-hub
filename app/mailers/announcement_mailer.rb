class AnnouncementMailer < ApplicationMailer
  def broadcast(announcement_id, to:)
    @announcement = Announcement.find(announcement_id)
    
    mail(
      to: to,
      subject: "📢 #{@announcement.title}"
    )
  end
end
