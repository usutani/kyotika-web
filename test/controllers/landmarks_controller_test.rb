require "test_helper"

class LandmarksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create_user!(name: "管理者", email_address: "admin@example.com", role: :administrator)
    @member = create_user!(name: "メンバー", email_address: "member@example.com")
    @other = create_user!(name: "他人", email_address: "other@example.com")
    @own = Landmark.create!(name: "自分の寺", hiragana: "じぶん", creator: @member)
    @others = Landmark.create!(name: "他人の寺", hiragana: "たにん", creator: @other)
  end

  test "unauthenticated index redirects to login" do
    get landmarks_path
    assert_redirected_to new_session_path
  end

  test "member sees only own landmarks" do
    sign_in_as(@member)
    get landmarks_path
    assert_response :success
    assert_includes response.body, "自分の寺"
    assert_not_includes response.body, "他人の寺"
  end

  test "admin sees all landmarks" do
    sign_in_as(@admin)
    get landmarks_path
    assert_response :success
    assert_includes response.body, "自分の寺"
    assert_includes response.body, "他人の寺"
  end

  test "member cannot edit others landmark" do
    sign_in_as(@member)
    get edit_landmark_path(@others)
    assert_response :not_found
  end

  test "member cannot update others landmark" do
    sign_in_as(@member)
    patch landmark_path(@others), params: { landmark: { name: "乗っ取り" } }
    assert_response :not_found
    assert_equal "他人の寺", @others.reload.name
  end

  test "create assigns current user as creator" do
    sign_in_as(@member)
    assert_difference("Landmark.count") do
      post landmarks_path, params: { landmark: { name: "新規", hiragana: "しんき" } }
    end
    assert_equal @member, Landmark.find_by(name: "新規").creator
    assert_redirected_to landmarks_path
  end

  test "member can destroy own landmark" do
    sign_in_as(@member)
    assert_difference("Landmark.count", -1) do
      delete landmark_path(@own)
    end
    assert_redirected_to landmarks_path
  end

  test "member cannot destroy others landmark" do
    sign_in_as(@member)
    assert_no_difference("Landmark.count") do
      delete landmark_path(@others)
    end
    assert_response :not_found
  end
end
