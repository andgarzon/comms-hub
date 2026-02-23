require "test_helper"

class SlackAudiencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "should get index" do
    get slack_audiences_url
    assert_response :success
  end

  test "should get new" do
    get new_slack_audience_url
    assert_response :success
  end

  test "should create slack audience" do
    assert_difference("SlackAudience.count") do
      post slack_audiences_url, params: { slack_audience: { name: "Slack Team", slack_channel: "#general", scope_type: "personal" } }
    end

    assert_redirected_to slack_audiences_url
  end

  test "should get edit" do
    audience = SlackAudience.create!(name: "Test Slack", slack_channel: "#test", scope_type: "personal", created_by_id: @user.id)
    get edit_slack_audience_url(audience)
    assert_response :success
  end

  test "should update slack audience" do
    audience = SlackAudience.create!(name: "Test Slack", slack_channel: "#test", scope_type: "personal", created_by_id: @user.id)
    patch slack_audience_url(audience), params: { slack_audience: { name: "Updated Slack", slack_channel: "#updated" } }
    assert_redirected_to slack_audiences_url
  end

  test "should destroy slack audience" do
    audience = SlackAudience.create!(name: "Test Slack", slack_channel: "#test", scope_type: "personal", created_by_id: @user.id)
    assert_difference("SlackAudience.count", -1) do
      delete slack_audience_url(audience)
    end

    assert_redirected_to slack_audiences_url
  end
end
