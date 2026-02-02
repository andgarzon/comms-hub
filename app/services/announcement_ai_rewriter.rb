class AnnouncementAiRewriter
  def initialize(announcement)
    @announcement = announcement
  end

  def call
    raise "OpenAI API key missing" if Rails.application.credentials.dig(:openai, :api_key).blank?

    prompt = <<~PROMPT
      You are a professional executive communications assistant.

      Task: Rewrite the ORIGINAL message into THREE tailored versions.
      Keep facts the same, improve clarity and tone.

      ORIGINAL:
      #{@announcement.base_body}

      Output EXACTLY in this format with these headers:
      EMAIL:
      <text>

      SLACK:
      <text>

      WHATSAPP:
      <text>
    PROMPT
    client = OpenAI::Client.new
    resp = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [{ role: "user", content: prompt }],
        temperature: 0.4
      }
    )

    content = resp.dig("choices", 0, "message", "content").to_s
    email, slack, whatsapp = parse(content)

    @announcement.update!(
      email_body: email.presence || @announcement.base_body,
      slack_body: slack.presence || @announcement.base_body,
      whatsapp_body: whatsapp.presence || @announcement.base_body
    )
  end

  private

  def parse(text)
    email = text[/EMAIL:\s*(.*?)\s*SLACK:/m, 1]
    slack = text[/SLACK:\s*(.*?)\s*WHATSAPP:/m, 1]
    whatsapp = text[/WHATSAPP:\s*(.*)\z/m, 1]
    [email&.strip, slack&.strip, whatsapp&.strip]
  end
end
