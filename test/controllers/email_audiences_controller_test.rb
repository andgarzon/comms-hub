require "test_helper"

class EmailAudiencesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get email_audiences_index_url
    assert_response :success
  end

  test "should get new" do
    get email_audiences_new_url
    assert_response :success
  end

  test "should get create" do
    get email_audiences_create_url
    assert_response :success
  end

  test "should get edit" do
    get email_audiences_edit_url
    assert_response :success
  end

  test "should get update" do
    get email_audiences_update_url
    assert_response :success
  end

  test "should get destroy" do
    get email_audiences_destroy_url
    assert_response :success
  end
end
