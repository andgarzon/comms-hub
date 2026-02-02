class SlackAnnouncementSender
  def initialize(announcement, channel: nil)
    @announcement = announcement
    @channel = channel.presence || Rails.application.credentials.dig(:slack, :default_channel)
    @client = Slack::Web::Client.new
  end

  def call
    raise "Missing Slack channel" if @channel.blank?

    text = "*#{@announcement.title}*\n\n#{@announcement.slack_body.presence || @announcement.base_body}"

    resp = @client.chat_postMessage(
      channel: @channel,
      text: text,
      mrkdwn: true
    )

    @announcement.delivery_logs.create!(
      channel: "slack",
      status: "sent",
      details: resp.to_s
    )

    resp
  rescue StandardError => e
    @announcement.delivery_logs.create!(
      channel: "slack",
      status: "error",
      details: e.message
    )
    raise
  end
end
