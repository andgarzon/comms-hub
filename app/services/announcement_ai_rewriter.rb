class AnnouncementAiRewriter
  def initialize(announcement)
    @announcement = announcement
  end

  def call
    setting = IntegrationSetting.for("openai")
    api_key = setting.api_key
    raise "OpenAI API key missing. Configure it in Settings > Integrations > OpenAI." if api_key.blank?

    model = setting.model_name

    prompt = <<~PROMPT
      You are a professional executive communications assistant.

      Task: Rewrite the ORIGINAL message into THREE tailored versions for different communication channels.
      Keep facts the same, improve clarity and tone.

      IMPORTANT LENGTH REQUIREMENTS:
      - EMAIL: Can be longer and more formal (multiple paragraphs OK)
      - SLACK: Must be SHORT - maximum 2-3 sentences, casual and direct
      - WHATSAPP: Must be VERY SHORT - maximum 1-2 sentences, conversational

      ORIGINAL:
      #{@announcement.base_body}

      Output EXACTLY in this format with these headers:
      EMAIL:
      <text>

      SLACK:
      <text - keep this SHORT, 2-3 sentences max>

      WHATSAPP:
      <text - keep this VERY SHORT, 1-2 sentences max>
    PROMPT

    client = OpenAI::Client.new(access_token: api_key)

    resp = client.chat(
      parameters: {
        model: model,
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
  rescue StandardError => e
    Rails.logger.error "AI Rewrite failed: #{e.class} - #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise "AI rewrite failed: #{e.message}"
  end

  private

  def parse(text)
    email = text[/EMAIL:\s*(.*?)\s*SLACK:/m, 1]
    slack = text[/SLACK:\s*(.*?)\s*WHATSAPP:/m, 1]
    whatsapp = text[/WHATSAPP:\s*(.*)\z/m, 1]
    [email&.strip, slack&.strip, whatsapp&.strip]
  end
end
