require "test_helper"

class Quiz::QuestionsControllerTest < ActionDispatch::IntegrationTest
  test "should get show when quiz started" do
    start_quiz(count: 1)
    assert_response :success
    assert_includes response.body, "問題 1 / 1"
  end

  test "should redirect to quiz path when no session" do
    get quiz_question_path
    assert_redirected_to quiz_path
  end

  test "should redirect to result when quiz finished" do
    landmark_id = start_quiz(count: 1)
    landmark = Landmark.find(landmark_id)

    post quiz_answer_path, params: {
      landmark_id: landmark.id,
      selected: landmark.correct
    }, as: :turbo_stream

    get quiz_question_path
    assert_redirected_to quiz_result_path
  end

  test "should redirect to quiz path when current landmark deleted" do
    start_quiz(count: 1)
    Landmark.destroy_all

    get quiz_question_path
    assert_redirected_to quiz_path
  end

  private

  def start_quiz(count: 1)
    post quiz_path, params: { count: count }
    assert_response :redirect
    follow_redirect!
    response.body.scan(/<input[^>]*name="landmark_id"[^>]*>/).first[/value="(\d+)"/, 1].to_i
  end
end
