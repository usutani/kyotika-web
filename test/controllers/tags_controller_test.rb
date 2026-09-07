require "test_helper"

class TagsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create_user!(name: "管理者", email_address: "admin@example.com", role: :administrator)
    @member = create_user!(name: "メンバー", email_address: "member@example.com")
    @tag = Tag.create!(name: "寺院")
  end

  test "member cannot destroy tag" do
    sign_in_as(@member)
    assert_no_difference("Tag.count") do
      delete tag_path(@tag)
    end
    assert_redirected_to root_path
  end

  test "admin can destroy tag" do
    sign_in_as(@admin)
    assert_difference("Tag.count", -1) do
      delete tag_path(@tag)
    end
    assert_redirected_to tags_path
  end

  test "member index hides delete button" do
    sign_in_as(@member)
    get tags_path
    assert_response :success
    assert_not_includes response.body, "削除"
  end

  test "member can still create tag inline" do
    sign_in_as(@member)
    assert_difference("Tag.count") do
      post tags_path, params: { tag: { name: "新規タグ" } }, as: :json
    end
    assert_response :created
  end
end
