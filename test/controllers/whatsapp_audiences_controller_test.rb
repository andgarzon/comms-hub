require "test_helper"

class WhatsappAudiencesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get whatsapp_audiences_index_url
    assert_response :success
  end

  test "should get new" do
    get whatsapp_audiences_new_url
    assert_response :success
  end

  test "should get create" do
    get whatsapp_audiences_create_url
    assert_response :success
  end

  test "should get edit" do
    get whatsapp_audiences_edit_url
    assert_response :success
  end

  test "should get update" do
    get whatsapp_audiences_update_url
    assert_response :success
  end

  test "should get destroy" do
    get whatsapp_audiences_destroy_url
    assert_response :success
  end
end
