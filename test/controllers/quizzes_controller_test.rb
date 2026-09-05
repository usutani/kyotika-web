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

  test "create redirects to quiz path when no landmarks" do
    Landmark.destroy_all
    post quiz_path, params: { count: 3 }
    assert_redirected_to quiz_path
  end
end
