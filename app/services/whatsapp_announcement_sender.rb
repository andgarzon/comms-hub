class WhatsappAnnouncementSender
  API_VERSION = "v18.0".freeze
  BASE_URL = "https://graph.facebook.com".freeze

  def initialize(announcement, phone:)
    @announcement = announcement
    @phone = phone

    setting = IntegrationSetting.for("whatsapp")
    raise "WhatsApp access token missing. Configure it in Settings > Integrations > WhatsApp." if setting.access_token.blank?
    raise "WhatsApp Phone Number ID missing. Configure it in Settings > Integrations > WhatsApp." if setting.phone_number_id.blank?

    @access_token = setting.access_token
    @phone_number_id = setting.phone_number_id
  end

  def call
    raise "Missing recipient phone number" if @phone.blank?

    body = @announcement.whatsapp_body.presence || @announcement.base_body
    message_text = "*#{@announcement.title}*\n\n#{body}"

    send_text_message(message_text)
  end

  private

  def send_text_message(text)
    uri = URI("#{BASE_URL}/#{API_VERSION}/#{@phone_number_id}/messages")

    payload = {
      messaging_product: "whatsapp",
      recipient_type: "individual",
      to: sanitize_phone(@phone),
      type: "text",
      text: { preview_url: false, body: text }
    }

    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Bearer #{@access_token}"
    request["Content-Type"] = "application/json"
    request.body = payload.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    parsed = JSON.parse(response.body)

    unless response.is_a?(Net::HTTPSuccess)
      error = parsed.dig("error", "message") || "HTTP #{response.code}: #{response.body}"
      raise "WhatsApp API error: #{error}"
    end

    parsed
  end

  def sanitize_phone(phone)
    phone.to_s.gsub(/[\s\-\(\)]+/, "").delete_prefix("+")
  end
end
