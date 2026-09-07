require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = Account.create!(name: "京チカ")
  end

  test "shows form with valid join code" do
    get join_path(join_code: @account.join_code)
    assert_response :success
  end

  test "returns 404 with invalid join code" do
    get join_path(join_code: "invalid-code-here")
    assert_response :not_found
  end

  test "registers member and signs in" do
    assert_difference("User.count") do
      post join_path(join_code: @account.join_code), params: { user: { name: "新人",
        email_address: "newcomer@example.com", password: "password123", password_confirmation: "password123" } }
    end
    user = User.find_by(email_address: "newcomer@example.com")
    assert user.member?
    assert_redirected_to root_path
    get landmarks_path
    assert_response :success
  end

  test "duplicate email redirects to login" do
    create_user!(name: "既存", email_address: "taken@example.com")
    assert_no_difference("User.count") do
      post join_path(join_code: @account.join_code), params: { user: { name: "別人",
        email_address: "taken@example.com", password: "password123", password_confirmation: "password123" } }
    end
    assert_redirected_to new_session_path
  end
end
