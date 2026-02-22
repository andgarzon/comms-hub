require "test_helper"
require "net/http"

class WhatsappAnnouncementSenderTest < ActiveSupport::TestCase
  setup do
    @setting = IntegrationSetting.find_or_initialize_by(provider: "whatsapp")
    @setting.config_data = {
      "phone_number_id" => "123456789",
      "access_token" => "test-access-token",
      "business_account_id" => "987654321",
      "sender_phone" => "15551234567"
    }
    @setting.status = "active"
    @setting.save!

    @announcement = Announcement.create!(
      title: "Test Announcement",
      base_body: "This is a test message.",
      whatsapp_body: "WhatsApp-optimized test message.",
      status: "sending",
      user: User.create!(email: "sender@test.com", password: "password123456", role: "admin")
    )
  end

  test "raises error when access token is missing" do
    @setting.update!(config_data: { "phone_number_id" => "123" })

    assert_raises(RuntimeError, /access token missing/i) do
      WhatsappAnnouncementSender.new(@announcement, phone: "+593991234567")
    end
  end

  test "raises error when phone number ID is missing" do
    @setting.update!(config_data: { "access_token" => "token" })

    assert_raises(RuntimeError, /Phone Number ID missing/i) do
      WhatsappAnnouncementSender.new(@announcement, phone: "+593991234567")
    end
  end

  test "raises error when recipient phone is blank" do
    sender = WhatsappAnnouncementSender.new(@announcement, phone: "")

    assert_raises(RuntimeError, /Missing recipient phone number/) do
      sender.call
    end
  end

  test "sends message using whatsapp_body when present" do
    success_response = Net::HTTPOK.new("1.1", "200", "OK")
    response_body = { "messages" => [{ "id" => "wamid.abc123" }] }.to_json

    success_response.stub(:body, response_body) do
      Net::HTTP.stub(:start, success_response) do
        result = WhatsappAnnouncementSender.new(@announcement, phone: "+593991234567").call
        assert_equal "wamid.abc123", result.dig("messages", 0, "id")
      end
    end
  end

  test "falls back to base_body when whatsapp_body is blank" do
    @announcement.update!(whatsapp_body: nil)

    success_response = Net::HTTPOK.new("1.1", "200", "OK")
    response_body = { "messages" => [{ "id" => "wamid.xyz789" }] }.to_json

    success_response.stub(:body, response_body) do
      Net::HTTP.stub(:start, success_response) do
        result = WhatsappAnnouncementSender.new(@announcement, phone: "+593991234567").call
        assert_equal "wamid.xyz789", result.dig("messages", 0, "id")
      end
    end
  end

  test "raises error on API failure" do
    error_response = Net::HTTPBadRequest.new("1.1", "400", "Bad Request")
    response_body = { "error" => { "message" => "Invalid phone number", "code" => 100 } }.to_json

    error_response.stub(:body, response_body) do
      Net::HTTP.stub(:start, error_response) do
        error = assert_raises(RuntimeError) do
          WhatsappAnnouncementSender.new(@announcement, phone: "+593991234567").call
        end
        assert_match(/Invalid phone number/, error.message)
      end
    end
  end

  test "sanitizes phone number by removing spaces, dashes, parens, and leading plus" do
    sender = WhatsappAnnouncementSender.new(@announcement, phone: "+593 (99) 123-4567")

    success_response = Net::HTTPOK.new("1.1", "200", "OK")
    response_body = { "messages" => [{ "id" => "wamid.sanitized" }] }.to_json

    success_response.stub(:body, response_body) do
      Net::HTTP.stub(:start, success_response) do
        result = sender.call
        assert result
      end
    end
  end
end
