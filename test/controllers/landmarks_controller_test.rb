require "test_helper"

class LandmarksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create_user!(name: "管理者", email_address: "admin@example.com", role: :administrator)
    @member = create_user!(name: "メンバー", email_address: "member@example.com")
    @other = create_user!(name: "他人", email_address: "other@example.com")
    @own = create_landmark!(name: "自分の寺", hiragana: "じぶん", creator: @member)
    @others = create_landmark!(name: "他人の寺", hiragana: "たにん", creator: @other)
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

  test "index shows add button right-aligned as primary action" do
    sign_in_as(@member)
    get landmarks_path
    assert_response :success
    assert_includes response.body, "btn btn--primary nav-links__right"
  end

  test "index shows slim columns with hidden values searchable" do
    sign_in_as(@admin)
    get landmarks_path
    assert_response :success
    assert_includes response.body, "<th>ID</th>"
    assert_not_includes response.body, "<th>緯度</th>"
    assert_not_includes response.body, "<th>問題</th>"
    assert_includes response.body, "data-search="
  end

  test "member does not see unassigned landmarks" do
    create_landmark!(name: "未割当の寺", hiragana: "みわりあて")
    sign_in_as(@member)
    get landmarks_path
    assert_response :success
    assert_not_includes response.body, "未割当の寺"
  end

  test "admin sees unassigned landmarks" do
    create_landmark!(name: "未割当の寺", hiragana: "みわりあて")
    sign_in_as(@admin)
    get landmarks_path
    assert_response :success
    assert_includes response.body, "未割当の寺"
  end

  test "member sees guidance when list is empty" do
    Landmark.destroy_all
    sign_in_as(@member)
    get landmarks_path
    assert_response :success
    assert_includes response.body, "自分の登録はまだありません"
  end

  test "admin sees guidance when list is empty" do
    Landmark.destroy_all
    sign_in_as(@admin)
    get landmarks_path
    assert_response :success
    assert_includes response.body, "seed を投入してください"
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
      post landmarks_path, params: { landmark: { name: "新規", hiragana: "しんき",
        question: "これは何ですか？", answer1: "答1", answer2: "答2", answer3: "答3", correct: 2,
        region_id: regions(:kyoto).id } }
    end
    assert_equal @member, Landmark.find_by(name: "新規").creator
    assert_redirected_to landmarks_path
  end

  test "index filters by region" do
    kobe_landmark = create_landmark!(name: "神戸の塔", hiragana: "こうべのとう", creator: @member, region: regions(:kobe))
    sign_in_as(@member)
    get landmarks_path, params: { region_id: regions(:kobe).id }
    assert_response :success
    assert_includes response.body, "神戸の塔"
    assert_not_includes response.body, "自分の寺"
  end

  test "index shows clear link when region filter is empty" do
    sign_in_as(@admin)
    get landmarks_path, params: { region_id: regions(:kobe).id }
    assert_response :success
    assert_includes response.body, "絞り込みをクリア"
  end

  test "member can destroy own landmark" do
    sign_in_as(@member)
    assert_difference("Landmark.count", -1) do
      delete landmark_path(@own)
    end
    assert_redirected_to landmarks_path
  end

  test "destroy preserves region filter" do
    kobe_landmark = create_landmark!(name: "神戸の塔", hiragana: "こうべのとう", creator: @member, region: regions(:kobe))
    sign_in_as(@member)
    assert_difference("Landmark.count", -1) do
      delete landmark_path(kobe_landmark, region_id: regions(:kobe).id)
    end
    assert_redirected_to landmarks_path(region_id: regions(:kobe).id)
  end

  test "member cannot destroy others landmark" do
    sign_in_as(@member)
    assert_no_difference("Landmark.count") do
      delete landmark_path(@others)
    end
    assert_response :not_found
  end
end
