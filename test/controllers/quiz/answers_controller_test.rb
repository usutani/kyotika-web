require "test_helper"

class Quiz::AnswersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @landmark = landmarks(:one)
  end

  test "should create answer with turbo stream" do
    start_quiz(count: 1)

    post quiz_answer_path, params: {
      landmark_id: @current_landmark.id,
      selected: @current_landmark.correct
    }, as: :turbo_stream

    assert_response :success
    assert_includes response.body, "turbo-stream"
  end

  test "should redirect to next question on html request" do
    start_quiz(count: 2)

    post quiz_answer_path, params: {
      landmark_id: @current_landmark.id,
      selected: @current_landmark.correct
    }

    assert_redirected_to quiz_question_path
  end

  test "should show results link on last question" do
    start_quiz(count: 1)

    post quiz_answer_path, params: {
      landmark_id: @current_landmark.id,
      selected: @current_landmark.correct
    }, as: :turbo_stream

    assert_response :success
    assert_includes response.body, "結果を見る"
  end

  test "should show correct label on correct answer" do
    start_quiz(count: 1)

    post quiz_answer_path, params: {
      landmark_id: @current_landmark.id,
      selected: @current_landmark.correct
    }, as: :turbo_stream

    assert_response :success
    assert_includes response.body, "正解！"
  end

  test "should show incorrect label on wrong answer" do
    start_quiz(count: 1)
    wrong_selected = @current_landmark.correct == 1 ? 2 : 1

    post quiz_answer_path, params: {
      landmark_id: @current_landmark.id,
      selected: wrong_selected
    }, as: :turbo_stream

    assert_response :success
    assert_includes response.body, "不正解"
  end

  test "should show correct answer text on wrong answer" do
    start_quiz(count: 1)
    wrong_selected = @current_landmark.correct == 1 ? 2 : 1

    post quiz_answer_path, params: {
      landmark_id: @current_landmark.id,
      selected: wrong_selected
    }, as: :turbo_stream

    assert_response :success
    correct_text = @current_landmark.send("answer#{@current_landmark.correct}")
    assert_includes response.body, correct_text
  end

  test "should redirect to question when landmark does not match current question" do
    start_quiz(count: 1)
    other = Landmark.where.not(id: @current_landmark.id).first

    post quiz_answer_path, params: {
      landmark_id: other.id,
      selected: other.correct
    }, as: :turbo_stream

    assert_redirected_to quiz_question_path
  end

  test "should not record mismatched answer" do
    start_quiz(count: 1)
    other = Landmark.where.not(id: @current_landmark.id).first

    post quiz_answer_path, params: {
      landmark_id: other.id,
      selected: other.correct
    }, as: :turbo_stream
    follow_redirect!

    post quiz_answer_path, params: {
      landmark_id: @current_landmark.id,
      selected: @current_landmark.correct
    }, as: :turbo_stream

    assert_response :success
    assert_includes response.body, "結果を見る"

    get quiz_result_path
    assert_includes response.body, "1 / 1"
  end

  test "should redirect to question when landmark does not exist" do
    start_quiz(count: 1)

    post quiz_answer_path, params: {
      landmark_id: Landmark.maximum(:id).to_i + 100,
      selected: 1
    }, as: :turbo_stream

    assert_redirected_to quiz_question_path
  end

  test "should redirect to question when selected is out of range" do
    start_quiz(count: 1)

    post quiz_answer_path, params: {
      landmark_id: @current_landmark.id,
      selected: 99
    }, as: :turbo_stream

    assert_redirected_to quiz_question_path
  end

  test "should redirect to result when answering after quiz finished" do
    start_quiz(count: 1)

    post quiz_answer_path, params: {
      landmark_id: @current_landmark.id,
      selected: @current_landmark.correct
    }, as: :turbo_stream

    post quiz_answer_path, params: {
      landmark_id: @current_landmark.id,
      selected: @current_landmark.correct
    }, as: :turbo_stream

    assert_redirected_to quiz_result_path
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
    @current_landmark = Landmark.find(current_landmark_id)
  end

  def current_landmark_id
    input = response.body.scan(/<input[^>]*name="landmark_id"[^>]*>/).first
    assert_not_nil input, "expected hidden landmark_id field in question page"
    input[/value="(\d+)"/, 1]
  end
end
