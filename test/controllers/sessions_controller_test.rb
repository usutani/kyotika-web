require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create_user!(name: "利用者", email_address: "user@example.com")
  end

  test "redirects to first run when no users exist" do
    User.delete_all
    get new_session_path
    assert_redirected_to first_run_path
  end

  test "login with valid credentials" do
    post session_path, params: { email_address: "user@example.com", password: "password123" }
    assert_redirected_to root_path
    get landmarks_path
    assert_response :success
  end

  test "login fails with wrong password" do
    post session_path, params: { email_address: "user@example.com", password: "wrongpass1" }
    assert_response :unauthorized
    get landmarks_path
    assert_redirected_to new_session_path
  end

  test "deactivated user cannot login" do
    @user.deactivate!
    post session_path, params: { email_address: "user@example.com", password: "password123" }
    assert_response :unauthorized
  end

  test "logout terminates session" do
    sign_in_as(@user)
    assert_difference("Session.count", -1) do
      delete session_path
    end
    assert_redirected_to root_path
    get landmarks_path
    assert_redirected_to new_session_path
  end

  test "returns to originally requested page after login" do
    get landmarks_path
    assert_redirected_to new_session_path
    post session_path, params: { email_address: "user@example.com", password: "password123" }
    assert_redirected_to landmarks_path
  end
end
