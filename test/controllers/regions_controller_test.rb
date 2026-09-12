require "test_helper"

class RegionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create_user!(name: "管理者", email_address: "admin@example.com", role: :administrator)
    @member = create_user!(name: "メンバー", email_address: "member@example.com")
  end

  test "index orders by hiragana" do
    sign_in_as(@member)
    get regions_path
    assert_response :success
    kyoto_pos = response.body.index("京都")
    kobe_pos = response.body.index("神戸市中央区")
    assert kyoto_pos < kobe_pos
  end

  test "member can create region" do
    sign_in_as(@member)
    assert_difference("Region.count") do
      post regions_path, params: { region: { name: "嵐山", hiragana: "あらしやま" } }
    end
    assert_redirected_to regions_path
  end

  test "member cannot destroy region" do
    sign_in_as(@member)
    assert_no_difference("Region.count") do
      delete region_path(regions(:kyoto))
    end
    assert_redirected_to root_path
  end

  test "admin can destroy empty region" do
    empty = Region.create!(name: "空地域", hiragana: "からちいき")
    sign_in_as(@admin)
    assert_difference("Region.count", -1) do
      delete region_path(empty)
    end
    assert_redirected_to regions_path
  end

  test "admin cannot destroy region with landmarks" do
    sign_in_as(@admin)
    assert_no_difference("Region.count") do
      delete region_path(regions(:kyoto))
    end
    assert_redirected_to regions_path
  end
end
