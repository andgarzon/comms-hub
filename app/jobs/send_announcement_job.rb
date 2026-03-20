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

    # Also send Slack DMs to contacts in non-Slack audiences that have slack_usernames
    announcement.audiences.where.not(type: "SlackAudience").each do |audience|
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

    # Send to slack_channel type contacts in any audience
    # Seed with channels already sent above from SlackAudience audiences
    sent_slack_channels = announcement.audiences.where(type: "SlackAudience").filter_map(&:slack_channel)
    announcement.audiences.each do |audience|
      audience.contact_slack_channels.each do |channel|
        next if sent_slack_channels.include?(channel)

        begin
          SlackAnnouncementSender.new(
            announcement,
            channel: channel
          ).call

          announcement.delivery_logs.create!(
            channel: "slack",
            destination: channel,
            status: "sent",
            details: "Slack channel contact in audience: #{audience.name}"
          )
          sent_slack_channels << channel
        rescue => e
          announcement.delivery_logs.create!(
            channel: "slack",
            destination: channel,
            status: "error",
            details: "#{e.class}: #{e.message}"
          )
        end
      end
    end

    # --------------------
    # EMAIL DELIVERY
    # --------------------
    sent_emails = []

    announcement.audiences.where(type: "EmailAudience").each do |audience|
      audience.email_list.each do |email|
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
            details: "Email audience: #{audience.name}"
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

    # Send to contacts with email addresses in any audience
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

    # --------------------
    # WHATSAPP DELIVERY
    # --------------------
    sent_phones = []

    announcement.audiences.where(type: "WhatsappAudience").each do |audience|
      audience.whatsapp_list.each do |phone|
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
            details: "WhatsApp audience: #{audience.name}"
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

    # Send to contacts with phone numbers in any audience
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

    announcement.update!(status: "sent")

    NotificationService.notify_sent(announcement, announcement.delivery_logs.reload)

  rescue => e
    if (announcement ||= Announcement.find_by(id: announcement_id))
      announcement.delivery_logs.create!(
        channel: "system",
        destination: "send_job",
        status: "error",
        details: "#{e.class}: #{e.message}"
      )
      announcement.update!(status: "failed")

      NotificationService.notify_failed(announcement, e.message)
    end

    raise
  end
end
