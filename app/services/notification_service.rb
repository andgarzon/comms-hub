class NotificationService
  def self.notify_sent(announcement, delivery_logs)
    notify(announcement, :sent, build_sent_summary(announcement, delivery_logs))
  end

  def self.notify_failed(announcement, error_message)
    notify(announcement, :failed, build_failed_summary(announcement, error_message))
  end

  private

  def self.notify(announcement, event, summary)
    user = announcement.user
    return unless user

    prefs = NotificationPreference.for(user)

    if prefs.wants_in_app?(event)
      user.notifications.create!(
        announcement: announcement,
        event: event.to_s,
        summary: summary
      )
    end

    if prefs.wants_email?(event)
      NotificationMailer.announcement_notification(user, announcement, event.to_s, summary).deliver_later
    end
  end

  def self.build_sent_summary(announcement, delivery_logs)
    successful = delivery_logs.select { |l| l.status == "sent" }
    failed = delivery_logs.select { |l| l.status == "error" }

    channels = successful.map(&:channel).uniq.map(&:capitalize).join(", ")
    parts = []
    parts << "Delivered to #{successful.size} #{'destination'.pluralize(successful.size)} via #{channels}" if successful.any?
    parts << "#{failed.size} #{'delivery'.pluralize(failed.size)} failed" if failed.any?
    parts.join(". ") + "."
  end

  def self.build_failed_summary(announcement, error_message)
    "Delivery failed: #{error_message}"
  end
end
