require "test_helper"

class LandmarksControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get landmarks_url
    assert_response :success
  end
end
