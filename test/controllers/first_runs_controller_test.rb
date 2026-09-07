require "test_helper"

class FirstRunsControllerTest < ActionDispatch::IntegrationTest
  setup do
    User.delete_all
    Account.delete_all
  end

  test "shows form when no users exist" do
    get first_run_path
    assert_response :success
  end

  test "creates first administrator and account" do
    assert_difference([ "User.count", "Account.count" ]) do
      post first_run_path, params: { user: { name: "初代", email_address: "first@example.com",
        password: "password123", password_confirmation: "password123" } }
    end
    user = User.find_by(email_address: "first@example.com")
    assert user.administrator?
    assert_redirected_to root_path
    get landmarks_path
    assert_response :success
  end

  test "prevents repeats once users exist" do
    create_user!(name: "既存", email_address: "exists@example.com", role: :administrator)
    get first_run_path
    assert_redirected_to root_path
    post first_run_path, params: { user: { name: "二重", email_address: "twice@example.com",
      password: "password123", password_confirmation: "password123" } }
    assert_redirected_to root_path
    assert_nil User.find_by(email_address: "twice@example.com")
  end
end
