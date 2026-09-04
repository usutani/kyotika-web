require "test_helper"

class MapQuizzesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get map_quiz_path
    assert_response :success
    assert_includes response.body, "map-quiz"
  end

  test "show embeds spots without answers" do
    get map_quiz_path
    assert_response :success
    assert_includes response.body, landmarks(:two).latitude.to_s
    assert_not_includes response.body, landmarks(:two).answer1
  end

  test "destroy clears found ids" do
    post map_quiz_answer_path, params: {
      landmark_id: landmarks(:two).id,
      selected: landmarks(:two).correct
    }
    assert_not_empty session[:map_quiz_found_ids]

    delete map_quiz_path
    assert_redirected_to map_quiz_path
    assert_nil session[:map_quiz_found_ids]
  end
end
