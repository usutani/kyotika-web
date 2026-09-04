require "test_helper"

class MapQuiz::QuestionsControllerTest < ActionDispatch::IntegrationTest
  test "should get show with landmark_id" do
    get map_quiz_question_path, params: { landmark_id: landmarks(:two).id }
    assert_response :success
    assert_includes response.body, landmarks(:two).question
    assert_not_includes response.body, "quiz__landmark-name"
  end

  test "returns not found without landmark_id" do
    get map_quiz_question_path, params: { landmark_id: 0 }
    assert_response :not_found
  end
end
