class SlackAnnouncementSender
  def initialize(announcement, channel:)
    @announcement = announcement
    @channel = channel
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

    resp
  end
end
