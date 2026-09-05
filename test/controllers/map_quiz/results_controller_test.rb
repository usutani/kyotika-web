require "test_helper"

class MapQuiz::ResultsControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to quiz path when not started" do
    get map_quiz_result_path
    assert_redirected_to quiz_path
  end

  test "should show score and spots after create" do
    post map_quiz_path, params: { map_count: 2 }

    get map_quiz_result_path
    assert_response :success
    assert_includes response.body, "発見率"
    assert_includes response.body, "0 / 2"
    assert_select "tbody tr", 2
  end

  test "should show found badge after correct answer" do
    post map_quiz_path, params: { map_count: 2 }
    post map_quiz_answer_path, params: {
      landmark_id: landmarks(:two).id,
      selected: landmarks(:two).correct
    }, headers: { "Accept" => "text/vnd.turbo-stream.html" }

    get map_quiz_result_path
    assert_response :success
    assert_includes response.body, "1 / 2"
    assert_includes response.body, "発見"
    assert_includes response.body, "未発見"
  end

  test "should mask hidden landmark name" do
    post map_quiz_path, params: { map_count: 2 }

    get map_quiz_result_path
    assert_response :success
    assert_includes response.body, "？？？"
  end

  test "should unmask names after reveal" do
    post map_quiz_path, params: { map_count: 2 }
    post map_quiz_answer_path, params: {
      landmark_id: landmarks(:two).id,
      selected: landmarks(:two).correct
    }, headers: { "Accept" => "text/vnd.turbo-stream.html" }

    get map_quiz_result_path
    assert_response :success
    assert_not_includes response.body, "？？？"
    assert_includes response.body, landmarks(:one).name
    assert_includes response.body, landmarks(:two).name
  end

  test "should link found landmark to map position" do
    post map_quiz_path, params: { map_count: 2 }
    post map_quiz_answer_path, params: {
      landmark_id: landmarks(:two).id,
      selected: landmarks(:two).correct
    }, headers: { "Accept" => "text/vnd.turbo-stream.html" }

    get map_quiz_result_path
    assert_response :success
    assert_select "a[href*='lat=#{landmarks(:two).latitude}'][href*='lng=#{landmarks(:two).longitude}']",
      text: landmarks(:two).name, count: 1
  end
end
