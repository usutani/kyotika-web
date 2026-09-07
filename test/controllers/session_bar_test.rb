require "test_helper"

class SessionBarTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create_user!(name: "管理者", email_address: "admin@example.com", role: :administrator)
    @member = create_user!(name: "メンバー", email_address: "member@example.com")
  end

  test "quiz pages do not show session bar" do
    get root_path
    assert_response :success
    assert_not_includes response.body, "session-bar"
  end

  test "signed in admin sees user info and management links" do
    sign_in_as(@admin)
    get landmarks_path
    assert_response :success
    assert_includes response.body, "session-bar"
    assert_includes response.body, "管理者（管理者）"
    assert_includes response.body, "メンバー管理"
    assert_includes response.body, "ログアウト"
    assert_not_includes response.body, ">ログイン<"
  end

  test "signed in member does not see management link" do
    sign_in_as(@member)
    get landmarks_path
    assert_response :success
    assert_includes response.body, "メンバー（メンバー）"
    assert_not_includes response.body, "メンバー管理"
  end

  test "login page shows top link instead of self login link" do
    get new_session_path
    assert_response :success
    assert_includes response.body, "session-bar"
    assert_includes response.body, ">トップ<"
    assert_not_includes response.body, "href=\"/session/new\""
  end
end
