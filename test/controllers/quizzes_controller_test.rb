require "test_helper"

class QuizzesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get quiz_path
    assert_response :success
  end

  test "show renders map quiz start form with full default count" do
    get quiz_path
    assert_response :success
    assert_select "form[action=?]", map_quiz_path do
      assert_select "input[name=map_count][value=?]", Landmark.where.not(latitude: nil, longitude: nil).count.to_s
      assert_select "input[type=submit][value=?]", "地図クイズスタート"
    end
  end

  test "show renders empty message when no landmarks" do
    Landmark.destroy_all
    get quiz_path
    assert_response :success
    assert_includes response.body, "まだありません"
  end

  test "show renders region selects with all regions option" do
    get quiz_path
    assert_response :success
    assert_select "select[name=region_id]", 2
    assert_includes response.body, "全地域"
    assert_includes response.body, regions(:kyoto).name
    assert_includes response.body, regions(:kobe).name
  end

  test "show filters totals by region" do
    kobe_landmark = create_landmark!(name: "神戸の塔", hiragana: "こうべのとう",
      latitude: 34.68, longitude: 135.19, region: regions(:kobe))
    get quiz_path, params: { region_id: regions(:kobe).id }
    assert_response :success
    assert_includes response.body, " / 1問"
  end

  test "create filters questions by region" do
    kobe_landmark = create_landmark!(name: "神戸の塔", hiragana: "こうべのとう", region: regions(:kobe))
    post quiz_path, params: { count: 5, region_id: regions(:kobe).id }
    assert_redirected_to quiz_question_path
    assert_equal [ kobe_landmark.id ], session[:quiz_question_ids]
  end

  test "create redirects to quiz path for unknown region" do
    post quiz_path, params: { count: 3, region_id: 999999 }
    assert_redirected_to quiz_path
  end

  test "create redirects to quiz path when no landmarks" do
    Landmark.destroy_all
    post quiz_path, params: { count: 3 }
    assert_redirected_to quiz_path
  end
end
