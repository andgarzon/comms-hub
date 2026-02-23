require "test_helper"
require "net/http"
require "minitest/mock"

class WhatsappAnnouncementSenderTest < ActiveSupport::TestCase
  MockResponse = Struct.new(:code, :body) do
    def is_a?(klass)
      return true if klass == Net::HTTPSuccess && code.to_i >= 200 && code.to_i < 300
      super
    end
  end

  MockHttp = Struct.new(:response) do
    def request(_req)
      response
    end
  end

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
      user: User.create!(email: "sender-#{SecureRandom.hex(4)}@test.com", password: "password123456", role: "admin")
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
    mock_response = MockResponse.new("200", { "messages" => [{ "id" => "wamid.abc123" }] }.to_json)
    fake_start = ->(*_args, **_kwargs, &block) { block.call(MockHttp.new(mock_response)) }

    Net::HTTP.stub(:start, fake_start) do
      result = WhatsappAnnouncementSender.new(@announcement, phone: "+593991234567").call
      assert_equal "wamid.abc123", result.dig("messages", 0, "id")
    end
  end

  test "falls back to base_body when whatsapp_body is blank" do
    @announcement.update!(whatsapp_body: nil)

    mock_response = MockResponse.new("200", { "messages" => [{ "id" => "wamid.xyz789" }] }.to_json)
    fake_start = ->(*_args, **_kwargs, &block) { block.call(MockHttp.new(mock_response)) }

    Net::HTTP.stub(:start, fake_start) do
      result = WhatsappAnnouncementSender.new(@announcement, phone: "+593991234567").call
      assert_equal "wamid.xyz789", result.dig("messages", 0, "id")
    end
  end

  test "raises error on API failure" do
    mock_response = MockResponse.new("400", { "error" => { "message" => "Invalid phone number", "code" => 100 } }.to_json)
    fake_start = ->(*_args, **_kwargs, &block) { block.call(MockHttp.new(mock_response)) }

    Net::HTTP.stub(:start, fake_start) do
      error = assert_raises(RuntimeError) do
        WhatsappAnnouncementSender.new(@announcement, phone: "+593991234567").call
      end
      assert_match(/Invalid phone number/, error.message)
    end
  end

  test "sanitizes phone number by removing spaces, dashes, parens, and leading plus" do
    sender = WhatsappAnnouncementSender.new(@announcement, phone: "+593 (99) 123-4567")

    mock_response = MockResponse.new("200", { "messages" => [{ "id" => "wamid.sanitized" }] }.to_json)
    fake_start = ->(*_args, **_kwargs, &block) { block.call(MockHttp.new(mock_response)) }

    Net::HTTP.stub(:start, fake_start) do
      result = sender.call
      assert result
    end
  end
end
