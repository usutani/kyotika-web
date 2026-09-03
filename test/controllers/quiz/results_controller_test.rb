require "test_helper"

class Quiz::ResultsControllerTest < ActionDispatch::IntegrationTest
  test "should show result after answering" do
    finish_quiz(count: 1)

    get quiz_result_path
    assert_response :success
    assert_includes response.body, "1 / 1"
  end

  test "should keep result on reload" do
    finish_quiz(count: 1)

    get quiz_result_path
    first_body = response.body

    get quiz_result_path
    assert_response :success
    assert_equal first_body, response.body
  end

  test "should redirect to quiz path when no answers" do
    get quiz_result_path
    assert_redirected_to quiz_path
  end

  test "should clear result after visiting start page" do
    finish_quiz(count: 1)

    get quiz_path
    assert_response :success

    get quiz_result_path
    assert_redirected_to quiz_path
  end

  private

  def finish_quiz(count: 1)
    post quiz_path, params: { count: count }
    assert_response :redirect
    follow_redirect!
    landmark = Landmark.find(current_landmark_id)

    post quiz_answer_path, params: {
      landmark_id: landmark.id,
      selected: landmark.correct
    }, as: :turbo_stream
  end

  def current_landmark_id
    input = response.body.scan(/<input[^>]*name="landmark_id"[^>]*>/).first
    assert_not_nil input, "expected hidden landmark_id field in question page"
    input[/value="(\d+)"/, 1]
  end
end
