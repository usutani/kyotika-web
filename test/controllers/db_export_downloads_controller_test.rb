require "test_helper"

class DbExportDownloadsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create_user!(name: "管理者", email_address: "admin@example.com", role: :administrator)
    @member = create_user!(name: "メンバー", email_address: "member@example.com")
  end

  test "unauthenticated redirects to login" do
    get db_export_download_path
    assert_redirected_to new_session_path
  end

  test "member redirects to root" do
    sign_in_as(@member)
    get db_export_download_path
    assert_redirected_to root_path
  end

  test "admin redirects to export page when file is missing" do
    with_export_dir do |_export_dir|
      sign_in_as(@admin)
      get db_export_download_path
      assert_redirected_to new_db_export_path
    end
  end

  test "admin downloads zip when file exists" do
    with_export_dir do |export_dir|
      File.write(export_dir.join("seeds.zip"), "fake-zip")

      sign_in_as(@admin)
      get db_export_download_path
      assert_response :success
      assert_equal "application/zip", response.media_type
    end
  end
end
