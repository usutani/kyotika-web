require "test_helper"

class InvalidUrlsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create_user!(name: "管理者", email_address: "admin@example.com", role: :administrator)
    @member = create_user!(name: "メンバー", email_address: "member@example.com")
  end

  test "unauthenticated redirects to login" do
    get invalid_urls_path
    assert_redirected_to new_session_path
  end

  test "member is forbidden" do
    sign_in_as(@member)
    get invalid_urls_path
    assert_redirected_to root_path
  end

  test "admin can access" do
    sign_in_as(@admin)
    get invalid_urls_path
    assert_response :success
  end

  test "member cannot trigger url check" do
    sign_in_as(@member)
    landmark = create_landmark!(name: "寺", hiragana: "てら", creator: @member)
    post url_checks_path, params: { landmark_id: landmark.id }
    assert_redirected_to root_path
  end
end
