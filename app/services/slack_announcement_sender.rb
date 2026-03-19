class SlackAnnouncementSender
  def initialize(announcement, channel: nil, user: nil)
    @announcement = announcement
    @channel = channel
    @user = user

    setting = IntegrationSetting.for("slack")
    raise "Slack bot token missing. Configure it in Settings > Integrations > Slack." if setting.bot_token.blank?

    @client = Slack::Web::Client.new(token: setting.bot_token)
  end

  def call
    raise "Missing Slack channel or user" if @channel.blank? && @user.blank?

    text = "*#{@announcement.title}*\n\n#{@announcement.slack_body.presence || @announcement.base_body}"

    target = @channel || @user

    resp = @client.chat_postMessage(
      channel: target,
      text: text,
      mrkdwn: true
    )

    resp
  end
end
