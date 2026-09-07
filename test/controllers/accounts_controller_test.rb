require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = Account.create!(name: "京チカ")
    @admin = create_user!(name: "管理者", email_address: "admin@example.com", role: :administrator)
    @member = create_user!(name: "メンバー", email_address: "member@example.com")
  end

  test "member cannot access account management" do
    sign_in_as(@member)
    get edit_account_path
    assert_redirected_to root_path
  end

  test "admin can access account management" do
    sign_in_as(@admin)
    get edit_account_path
    assert_response :success
  end

  test "admin promotes member to administrator" do
    sign_in_as(@admin)
    patch account_user_path(@member), params: { user: { role: "administrator" } }
    assert_redirected_to edit_account_path
    assert @member.reload.administrator?
  end

  test "admin cannot demote self" do
    sign_in_as(@admin)
    patch account_user_path(@admin), params: { user: { role: "member" } }
    assert_redirected_to edit_account_path
    assert @admin.reload.administrator?
  end

  test "cannot demote last administrator" do
    sign_in_as(@admin)
    patch account_user_path(@admin), params: { user: { role: "member" } }
    assert @admin.reload.administrator?
    other = create_user!(name: "副管理", email_address: "sub@example.com", role: :administrator)
    patch account_user_path(other), params: { user: { role: "member" } }
    assert other.reload.member?
  end

  test "deactivate and reactivate are reversible" do
    sign_in_as(@admin)
    landmark = Landmark.create!(name: "残す寺", hiragana: "のこす", creator: @member)

    post account_user_deactivation_path(@member)
    assert_redirected_to edit_account_path
    assert @member.reload.deactivated?
    assert_equal @member, landmark.reload.creator

    post session_path, params: { email_address: "member@example.com", password: "password123" }
    assert_response :unauthorized

    delete account_user_deactivation_path(@member)
    assert @member.reload.active?

    post session_path, params: { email_address: "member@example.com", password: "password123" }
    assert_redirected_to root_path
  end

  test "admin cannot deactivate self" do
    sign_in_as(@admin)
    post account_user_deactivation_path(@admin)
    assert_redirected_to edit_account_path
    assert @admin.reload.active?
  end

  test "admin resets member password and kills sessions" do
    sign_in_as(@member)
    sign_in_as(@admin)
    patch account_user_password_path(@member), params: { user: { password: "newpass123", password_confirmation: "newpass123" } }
    assert_redirected_to edit_account_path
    assert_equal 0, @member.sessions.count
    post session_path, params: { email_address: "member@example.com", password: "newpass123" }
    assert_redirected_to root_path
  end

  test "join code regeneration invalidates old url" do
    sign_in_as(@admin)
    old_code = @account.reload.join_code
    post account_join_code_path
    assert_redirected_to edit_account_path
    assert_not_equal old_code, @account.reload.join_code
    get join_path(join_code: old_code)
    assert_response :not_found
  end
end
