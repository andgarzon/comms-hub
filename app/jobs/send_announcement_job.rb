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
        begin
          SlackAnnouncementSender.new(
            announcement,
            channel: audience.slack_channel
          ).call

          announcement.delivery_logs.create!(
            channel: "slack",
            destination: audience.slack_channel,
            status: "sent",
            details: "Slack audience: #{audience.name}"
          )
        rescue => e
          announcement.delivery_logs.create!(
            channel: "slack",
            destination: audience.slack_channel,
            status: "error",
            details: "#{e.class}: #{e.message}"
          )
        end
      end
    end

    # --------------------
    # EMAIL DELIVERY
    # --------------------
    if announcement.send_to_email?
      announcement.audiences.where(type: "EmailAudience").each do |audience|
        audience.email_list.each do |email|
          begin
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
          rescue => e
            announcement.delivery_logs.create!(
              channel: "email",
              destination: email,
              status: "error",
              details: "#{e.class}: #{e.message}"
            )
          end
        end
      end
    end

    # --------------------
    # WHATSAPP (placeholder for now)
    # --------------------
    if announcement.send_to_whatsapp?
      announcement.audiences.where(type: "WhatsappAudience").each do |audience|
        audience.whatsapp_list.each do |phone|
          # TODO: Implement WhatsApp API integration
          announcement.delivery_logs.create!(
            channel: "whatsapp",
            destination: phone,
            status: "pending",
            details: "WhatsApp delivery not yet implemented. Audience: #{audience.name}"
          )
        end
      end
    end

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
