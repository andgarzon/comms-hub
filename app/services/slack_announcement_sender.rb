class SlackAnnouncementSender
  def initialize(announcement)
    @announcement = announcement
    @client = Slack::Web::Client.new
  end

  def call
    channels = target_channels
    raise "No Slack channels configured for selected audiences" if channels.empty?

    text = "*#{@announcement.title}*\n\n#{@announcement.body}"

    channels.each do |channel|
      post_one(channel, text)
    end
  end

  private

  def target_channels
    @announcement.audiences.map { |a| a.slack_channel.to_s.strip }.reject(&:blank?).uniq
  end

  def post_one(channel, text)
    log = @announcement.delivery_logs.find_or_create_by!(
      channel: "slack",
      destination: channel
    ) do |l|
      l.status = "sending"
      l.details = ""
    end

    # If it was already marked sent, do nothing (prevents double posts)
    return if log.status == "sent"

    resp = @client.chat_postMessage(channel: channel, text: text, mrkdwn: true)

    log.update!(
      status: "sent",
      details: "resp=#{resp.to_s}"
    )
  rescue StandardError => e
    @announcement.delivery_logs.find_or_create_by!(channel: "slack", destination: channel)
               .update!(status: "error", details: "#{e.class}: #{e.message}")
    raise
  end
end
