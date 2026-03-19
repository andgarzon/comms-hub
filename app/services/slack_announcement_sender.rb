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

    target = if @user.present?
      # Open a DM conversation with the user first, then send to that channel
      dm = @client.conversations_open(users: @user.delete_prefix("@"))
      dm.channel.id
    else
      @channel
    end

    @client.chat_postMessage(
      channel: target,
      text: text,
      mrkdwn: true
    )
  end
end
