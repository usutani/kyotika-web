require "test_helper"

class Quiz::AnswersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @landmark = landmarks(:one)
  end

  test "should create answer with turbo stream" do
    start_quiz(count: 1)

    post quiz_answer_path, params: {
      landmark_id: @landmark.id,
      selected: @landmark.correct
    }, as: :turbo_stream

    assert_response :success
    assert_includes response.body, "turbo-stream"
  end

  test "should redirect to next question on html request" do
    start_quiz(count: 2)

    post quiz_answer_path, params: {
      landmark_id: @landmark.id,
      selected: @landmark.correct
    }

    assert_redirected_to quiz_question_path
  end

  test "should show results link on last question" do
    start_quiz(count: 1)

    post quiz_answer_path, params: {
      landmark_id: @landmark.id,
      selected: @landmark.correct
    }, as: :turbo_stream

    assert_response :success
    assert_includes response.body, "結果を見る"
  end

  test "should show correct label on correct answer" do
    start_quiz(count: 1)

    post quiz_answer_path, params: {
      landmark_id: @landmark.id,
      selected: @landmark.correct
    }, as: :turbo_stream

    assert_response :success
    assert_includes response.body, "正解！"
  end

  test "should show incorrect label on wrong answer" do
    start_quiz(count: 1)
    wrong_selected = @landmark.correct == 1 ? 2 : 1

    post quiz_answer_path, params: {
      landmark_id: @landmark.id,
      selected: wrong_selected
    }, as: :turbo_stream

    assert_response :success
    assert_includes response.body, "不正解"
  end

  test "should show correct answer text on wrong answer" do
    start_quiz(count: 1)
    wrong_selected = @landmark.correct == 1 ? 2 : 1

    post quiz_answer_path, params: {
      landmark_id: @landmark.id,
      selected: wrong_selected
    }, as: :turbo_stream

    assert_response :success
    correct_text = @landmark.send("answer#{@landmark.correct}")
    assert_includes response.body, correct_text
  end

  test "should redirect to quiz path when no session" do
    post quiz_answer_path, params: {
      landmark_id: @landmark.id,
      selected: 1
    }

    assert_redirected_to quiz_path
  end

  private

  def start_quiz(count: 1)
    post quiz_path, params: { count: count }
    assert_response :redirect
    follow_redirect!
  end
end
