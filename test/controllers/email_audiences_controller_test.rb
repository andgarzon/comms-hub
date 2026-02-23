require "test_helper"

class EmailAudiencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "should get index" do
    get email_audiences_url
    assert_response :success
  end

  test "should get new" do
    get new_email_audience_url
    assert_response :success
  end

  test "should create email audience" do
    assert_difference("EmailAudience.count") do
      post email_audiences_url, params: { email_audience: { name: "Email Team", email_recipients: "test@example.com", scope_type: "personal" } }
    end

    assert_redirected_to email_audiences_url
  end

  test "should get edit" do
    audience = EmailAudience.create!(name: "Test Email", email_recipients: "a@b.com", scope_type: "personal", created_by_id: @user.id)
    get edit_email_audience_url(audience)
    assert_response :success
  end

  test "should update email audience" do
    audience = EmailAudience.create!(name: "Test Email", email_recipients: "a@b.com", scope_type: "personal", created_by_id: @user.id)
    patch email_audience_url(audience), params: { email_audience: { name: "Updated Email", email_recipients: "new@example.com" } }
    assert_redirected_to email_audiences_url
  end

  test "should destroy email audience" do
    audience = EmailAudience.create!(name: "Test Email", email_recipients: "a@b.com", scope_type: "personal", created_by_id: @user.id)
    assert_difference("EmailAudience.count", -1) do
      delete email_audience_url(audience)
    end

    assert_redirected_to email_audiences_url
  end
end
