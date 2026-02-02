class SendAnnouncementJob < ApplicationJob
  queue_as :default

  def perform(announcement_id)
    announcement = Announcement.find(announcement_id)

    # Already sent? Do nothing.
    return if announcement.status == "sent"

    # Stale scheduled job? Do nothing.
    if announcement.status == "scheduled" &&
       announcement.scheduled_for.present? &&
       announcement.scheduled_for.future?
      return
    end

    announcement.update!(status: "sending")

    # --------------------
    # SLACK DELIVERY
    # --------------------
    if announcement.send_to_slack?
      announcement.audiences.where(type: "SlackAudience").each do |audience|
        SlackAnnouncementSender.new(
          announcement,
          audience.slack_channel
        ).call

        announcement.delivery_logs.create!(
          channel: "slack",
          destination: audience.slack_channel,
          status: "sent",
          details: "Slack audience: #{audience.name}"
        )
      end
    end

    # --------------------
    # EMAIL DELIVERY
    # --------------------
    if announcement.send_to_email?
      announcement.audiences.where(type: "EmailAudience").each do |audience|
        audience.email_list.each do |email|
          AnnouncementMailer.broadcast(
            announcement.id,
            to: email
          ).deliver_now

          announcement.delivery_logs.create!(
            channel: "email",
            destination: email,
            status: "sent",
            details: "Email audience: #{audience.name}"
          )
        end
      end
    end

    # --------------------
    # WHATSAPP (future)
    # --------------------
    # announcement.audiences.where(type: "WhatsappAudience")

    announcement.update!(status: "sent")

  rescue => e
    if (announcement ||= Announcement.find_by(id: announcement_id))
      announcement.delivery_logs.create!(
        channel: "system",
        destination: "send_job",
        status: "error",
        details: "#{e.class}: #{e.message}"
      )
      announcement.update!(status: "failed")
    end

    raise
  end
end

