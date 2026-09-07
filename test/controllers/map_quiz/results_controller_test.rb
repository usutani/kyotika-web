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
    assert_select "[data-pane-name=list] tbody tr", 2
    assert_select "a.btn--secondary[href=?]", map_quiz_path(resume: true), text: "地図に戻る", count: 2
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

  test "should show tag groups pane" do
    tag = Tag.create!(name: "寺院")
    Tagging.create!(landmark: landmarks(:one), tag: tag)
    post map_quiz_path, params: { map_count: 2 }
    post map_quiz_answer_path, params: {
      landmark_id: landmarks(:one).id,
      selected: landmarks(:one).correct
    }, headers: { "Accept" => "text/vnd.turbo-stream.html" }

    get map_quiz_result_path
    assert_response :success
    assert_select "[role=tablist] [role=tab]", count: 2
    assert_includes response.body, "タグ別"
    assert_includes response.body, "寺院"
    assert_includes response.body, landmarks(:one).name
  end

  test "should show untagged group" do
    create_landmark!(name: "無名庵", hiragana: "むみょうあん", latitude: 35.0, longitude: 135.7)
    post map_quiz_path, params: { map_count: 3 }
    %i[one two].each do |name|
      landmark = landmarks(name)
      post map_quiz_answer_path, params: { landmark_id: landmark.id, selected: landmark.correct },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end

    get map_quiz_result_path
    assert_response :success
    assert_includes response.body, "タグなし"
    assert_includes response.body, "無名庵"
  end

  test "should link found landmark to map position" do
    post map_quiz_path, params: { map_count: 2 }
    post map_quiz_answer_path, params: {
      landmark_id: landmarks(:two).id,
      selected: landmarks(:two).correct
    }, headers: { "Accept" => "text/vnd.turbo-stream.html" }

    get map_quiz_result_path
    assert_response :success
    assert_select "[data-pane-name=list] a[href*='lat=#{landmarks(:two).latitude}'][href*='lng=#{landmarks(:two).longitude}']",
      text: landmarks(:two).name, count: 1
  end
end
