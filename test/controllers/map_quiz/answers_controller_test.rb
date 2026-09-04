require "test_helper"

class MapQuiz::AnswersControllerTest < ActionDispatch::IntegrationTest
  test "correct answer records found id" do
    landmark = landmarks(:two)

    post map_quiz_answer_path, params: { landmark_id: landmark.id, selected: landmark.correct },
      headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
    assert_includes session[:map_quiz_found_ids], landmark.id
  end

  test "incorrect answer does not record found id" do
    landmark = landmarks(:two)
    wrong = (landmark.correct % 3) + 1

    post map_quiz_answer_path, params: { landmark_id: landmark.id, selected: wrong },
      headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
    assert_not_includes Array(session[:map_quiz_found_ids]), landmark.id
  end

  test "invalid selected returns unprocessable entity" do
    post map_quiz_answer_path, params: { landmark_id: landmarks(:two).id, selected: 9 }
    assert_response :unprocessable_entity
  end
end
