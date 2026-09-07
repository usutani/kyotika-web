require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create_user!(name: "利用者", email_address: "user@example.com")
    sign_in_as(@user)
  end

  test "shows profile" do
    get profile_path
    assert_response :success
  end

  test "updates name without password" do
    patch profile_path, params: { user: { name: "改名" } }
    assert_redirected_to profile_path
    assert_equal "改名", @user.reload.name
  end

  test "changes password with current password" do
    patch profile_path, params: { user: { name: "利用者", current_password: "password123",
      password: "changed123", password_confirmation: "changed123" } }
    assert_redirected_to profile_path
    delete session_path
    post session_path, params: { email_address: "user@example.com", password: "changed123" }
    assert_redirected_to root_path
  end

  test "rejects password change with wrong current password" do
    patch profile_path, params: { user: { name: "利用者", current_password: "wrongpass1",
      password: "changed123", password_confirmation: "changed123" } }
    assert_response :unprocessable_entity
    delete session_path
    post session_path, params: { email_address: "user@example.com", password: "changed123" }
    assert_response :unauthorized
  end
end
