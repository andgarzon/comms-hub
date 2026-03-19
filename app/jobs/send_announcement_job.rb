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
      sent_slack_users = []

      announcement.audiences.where(type: "SlackAudience").each do |audience|
        # Send to channel
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

        # Send DMs to contacts with slack usernames
        audience.contact_slack_usernames.each do |slack_username|
          next if sent_slack_users.include?(slack_username)

          begin
            SlackAnnouncementSender.new(
              announcement,
              user: slack_username
            ).call

            announcement.delivery_logs.create!(
              channel: "slack",
              destination: slack_username,
              status: "sent",
              details: "Contact DM in audience: #{audience.name}"
            )
            sent_slack_users << slack_username
          rescue => e
            announcement.delivery_logs.create!(
              channel: "slack",
              destination: slack_username,
              status: "error",
              details: "#{e.class}: #{e.message}"
            )
          end
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

      # Send to contacts linked to any audience (via email)
      sent_emails = announcement.delivery_logs.where(channel: "email", status: "sent").pluck(:destination)
      announcement.audiences.each do |audience|
        audience.contact_emails.each do |email|
          next if sent_emails.include?(email)
          begin
            AnnouncementMailer.broadcast(
              announcement.id,
              to: email
            ).deliver_now

            announcement.delivery_logs.create!(
              channel: "email",
              destination: email,
              status: "sent",
              details: "Contact in audience: #{audience.name}"
            )
            sent_emails << email
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
    # WHATSAPP DELIVERY
    # --------------------
    if announcement.send_to_whatsapp?
      announcement.audiences.where(type: "WhatsappAudience").each do |audience|
        audience.whatsapp_list.each do |phone|
          begin
            WhatsappAnnouncementSender.new(
              announcement,
              phone: phone
            ).call

            announcement.delivery_logs.create!(
              channel: "whatsapp",
              destination: phone,
              status: "sent",
              details: "WhatsApp audience: #{audience.name}"
            )
          rescue => e
            announcement.delivery_logs.create!(
              channel: "whatsapp",
              destination: phone,
              status: "error",
              details: "#{e.class}: #{e.message}"
            )
          end
        end
      end
    end

    # --------------------
    # WHATSAPP DELIVERY (contacts)
    # --------------------
    if announcement.send_to_whatsapp?
      sent_phones = announcement.delivery_logs.where(channel: "whatsapp", status: "sent").pluck(:destination)
      announcement.audiences.each do |audience|
        audience.contact_phones.each do |phone|
          next if sent_phones.include?(phone)
          begin
            WhatsappAnnouncementSender.new(
              announcement,
              phone: phone
            ).call

            announcement.delivery_logs.create!(
              channel: "whatsapp",
              destination: phone,
              status: "sent",
              details: "Contact in audience: #{audience.name}"
            )
            sent_phones << phone
          rescue => e
            announcement.delivery_logs.create!(
              channel: "whatsapp",
              destination: phone,
              status: "error",
              details: "#{e.class}: #{e.message}"
            )
          end
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
