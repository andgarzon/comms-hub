require "test_helper"

class WhatsappAudiencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "should get index" do
    get whatsapp_audiences_url
    assert_response :success
  end

  test "should get new" do
    get new_whatsapp_audience_url
    assert_response :success
  end

  test "should create whatsapp audience" do
    assert_difference("WhatsappAudience.count") do
      post whatsapp_audiences_url, params: { whatsapp_audience: { name: "WhatsApp Team", whatsapp_recipients: "+1234567890", scope_type: "personal" } }
    end

    assert_redirected_to whatsapp_audiences_url
  end

  test "should get edit" do
    audience = WhatsappAudience.create!(name: "Test WA", whatsapp_recipients: "+1234567890", scope_type: "personal", created_by_id: @user.id)
    get edit_whatsapp_audience_url(audience)
    assert_response :success
  end

  test "should update whatsapp audience" do
    audience = WhatsappAudience.create!(name: "Test WA", whatsapp_recipients: "+1234567890", scope_type: "personal", created_by_id: @user.id)
    patch whatsapp_audience_url(audience), params: { whatsapp_audience: { name: "Updated WA", whatsapp_recipients: "+0987654321" } }
    assert_redirected_to whatsapp_audiences_url
  end

  test "should destroy whatsapp audience" do
    audience = WhatsappAudience.create!(name: "Test WA", whatsapp_recipients: "+1234567890", scope_type: "personal", created_by_id: @user.id)
    assert_difference("WhatsappAudience.count", -1) do
      delete whatsapp_audience_url(audience)
    end

    assert_redirected_to whatsapp_audiences_url
  end
end
