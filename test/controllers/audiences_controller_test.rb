require "test_helper"

class AudiencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @audience = audiences(:one)
  end

  test "should get index" do
    get audiences_url
    assert_response :success
  end

  test "should get new" do
    get new_audience_url
    assert_response :success
  end

  test "should create audience" do
    assert_difference("Audience.count") do
      post audiences_url, params: { audience: { description: @audience.description, name: @audience.name, slack_channel: @audience.slack_channel } }
    end

    assert_redirected_to audience_url(Audience.last)
  end

  test "should show audience" do
    get audience_url(@audience)
    assert_response :success
  end

  test "should get edit" do
    get edit_audience_url(@audience)
    assert_response :success
  end

  test "should update audience" do
    patch audience_url(@audience), params: { audience: { description: @audience.description, name: @audience.name, slack_channel: @audience.slack_channel } }
    assert_redirected_to audience_url(@audience)
  end

  test "should destroy audience" do
    assert_difference("Audience.count", -1) do
      delete audience_url(@audience)
    end

    assert_redirected_to audiences_url
  end
end
