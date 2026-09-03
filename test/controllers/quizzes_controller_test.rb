require "test_helper"

class QuizzesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get quiz_path
    assert_response :success
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
