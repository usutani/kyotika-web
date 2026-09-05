require "test_helper"

class MapQuiz::AnswersControllerTest < ActionDispatch::IntegrationTest
  test "correct answer records found id" do
    landmark = landmarks(:two)

    post map_quiz_answer_path, params: { landmark_id: landmark.id, selected: landmark.correct },
      headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
    assert_includes session[:map_quiz_found_ids], landmark.id
    assert_includes response.body, "発見 1 / 2"
  end

  test "incorrect answer does not record found id" do
    landmark = landmarks(:two)
    wrong = (landmark.correct % 3) + 1

    post map_quiz_answer_path, params: { landmark_id: landmark.id, selected: wrong },
      headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
    assert_not_includes Array(session[:map_quiz_found_ids]), landmark.id
    assert_includes response.body, "発見 0 / 2"
  end

  test "invalid selected returns unprocessable entity" do
    post map_quiz_answer_path, params: { landmark_id: landmarks(:two).id, selected: 9 }
    assert_response :unprocessable_entity
  end

  test "complete shows result link" do
    post map_quiz_path, params: { map_count: 2 }

    %i[one two].each do |name|
      landmark = landmarks(name)
      post map_quiz_answer_path, params: { landmark_id: landmark.id, selected: landmark.correct },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }
      assert_response :success
    end

    assert_includes response.body, "発見記録を見る"
    assert_includes response.body, map_quiz_result_path
  end
end
