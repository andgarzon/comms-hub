class SlackAnnouncementSender
  def initialize(announcement, channel:)
    @announcement = announcement
    @channel = channel

    setting = IntegrationSetting.for("slack")
    raise "Slack bot token missing. Configure it in Settings > Integrations > Slack." if setting.bot_token.blank?

    @client = Slack::Web::Client.new(token: setting.bot_token)
  end

  def call
    raise "Missing Slack channel" if @channel.blank?

    text = "*#{@announcement.title}*\n\n#{@announcement.slack_body.presence || @announcement.base_body}"

    resp = @client.chat_postMessage(
      channel: @channel,
      text: text,
      mrkdwn: true
    )

    resp
  end
end
