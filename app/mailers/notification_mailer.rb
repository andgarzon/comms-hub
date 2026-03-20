class NotificationMailer < ApplicationMailer
  def announcement_notification(user, announcement, event, summary)
    @user = user
    @announcement = announcement
    @event = event
    @summary = summary

    subject = if event == "sent"
      "Announcement delivered: #{announcement.title}"
    else
      "Announcement failed: #{announcement.title}"
    end

    mail(to: user.email, subject: subject)
  end
end
