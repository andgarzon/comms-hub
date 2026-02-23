require "test_helper"

class AnnouncementsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
    @announcement = announcements(:one)
  end

  test "should get index" do
    get announcements_url
    assert_response :success
  end

  test "should get new" do
    get new_announcement_url
    assert_response :success
  end

  test "should show announcement" do
    get announcement_url(@announcement)
    assert_response :success
  end
end
