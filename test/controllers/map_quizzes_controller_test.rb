require "test_helper"

class MapQuizzesControllerTest < ActionDispatch::IntegrationTest
  test "create sets target ids and redirects to map" do
    post map_quiz_path, params: { map_count: 1 }
    assert_redirected_to map_quiz_path
    assert_equal 1, session[:map_quiz_target_ids].size
  end

  test "create redirects to quiz path when no landmarks" do
    Landmark.destroy_all
    post map_quiz_path, params: { map_count: 1 }
    assert_redirected_to quiz_path
  end

  test "show redirects to quiz path when not started" do
    get map_quiz_path
    assert_redirected_to quiz_path
  end

  test "show embeds spots without answers after create" do
    post map_quiz_path, params: { map_count: 2 }

    get map_quiz_path
    assert_response :success
    assert_includes response.body, landmarks(:two).latitude.to_s
    assert_not_includes response.body, landmarks(:two).answer1
    assert_includes response.body, "data-map-quiz-fit-bounds-value=\"true\""
  end

  test "show centers on given coordinates" do
    post map_quiz_path, params: { map_count: 2 }

    get map_quiz_path, params: { lat: landmarks(:two).latitude, lng: landmarks(:two).longitude }
    assert_response :success
    assert_includes response.body, [ landmarks(:two).latitude, landmarks(:two).longitude ].to_json
    assert_includes response.body, "data-map-quiz-zoom-value=\"#{MapQuizzesController::FOCUS_ZOOM}\""
    assert_includes response.body, "data-map-quiz-fit-bounds-value=\"false\""
  end

  test "show falls back to initial center on invalid coordinates" do
    post map_quiz_path, params: { map_count: 2 }

    get map_quiz_path, params: { lat: "invalid", lng: "" }
    assert_response :success
    assert_includes response.body, MapQuizzesController::INITIAL_CENTER.to_json
    assert_includes response.body, "data-map-quiz-zoom-value=\"#{MapQuizzesController::INITIAL_ZOOM}\""
  end

  test "show renders quit button with confirm dialog" do
    post map_quiz_path, params: { map_count: 2 }

    get map_quiz_path
    assert_response :success
    assert_select 'input[data-turbo-confirm="発見記録をリセットしますか？"][value="地図クイズをやめる"]'
  end

  test "destroy clears target and found ids" do
    post map_quiz_path, params: { map_count: 2 }
    post map_quiz_answer_path, params: {
      landmark_id: landmarks(:two).id,
      selected: landmarks(:two).correct
    }, headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_not_empty session[:map_quiz_found_ids]

    delete map_quiz_path
    assert_redirected_to quiz_path
    assert_nil session[:map_quiz_target_ids]
    assert_nil session[:map_quiz_found_ids]
  end
end
