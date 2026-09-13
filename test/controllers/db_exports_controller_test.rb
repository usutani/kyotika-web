require "test_helper"

class DbExportsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @admin = create_user!(name: "管理者", email_address: "admin@example.com", role: :administrator)
    @member = create_user!(name: "メンバー", email_address: "member@example.com")
  end

  test "unauthenticated create redirects to login" do
    post db_export_path
    assert_redirected_to new_session_path
  end

  test "unauthenticated show redirects to login" do
    get db_export_path
    assert_redirected_to new_session_path
  end

  test "member create redirects to root" do
    sign_in_as(@member)
    post db_export_path
    assert_redirected_to root_path
  end

  test "member show redirects to root" do
    sign_in_as(@member)
    get db_export_path
    assert_redirected_to root_path
  end

  test "admin create enqueues job and clears stale status" do
    with_export_dir do |export_dir|
      File.write(export_dir.join("status"), "completed")
      File.write(export_dir.join("seeds.zip"), "stale")

      sign_in_as(@admin)
      assert_enqueued_with(job: SeedsDumpJob) do
        post db_export_path
      end
      assert_redirected_to db_export_path
      assert_not export_dir.join("status").exist?
      assert_not export_dir.join("seeds.zip").exist?
    end
  end

  test "admin show renders processing when no status" do
    with_export_dir do |_export_dir|
      sign_in_as(@admin)
      get db_export_path
      assert_response :success
      assert_includes response.body, "エクスポート中"
    end
  end

  test "admin show renders completed when status is completed" do
    with_export_dir do |export_dir|
      File.write(export_dir.join("status"), "completed")

      sign_in_as(@admin)
      get db_export_path
      assert_response :success
      assert_includes response.body, "エクスポートが完了"
    end
  end

  test "admin show renders failure when status is failed" do
    with_export_dir do |export_dir|
      File.write(export_dir.join("status"), "failed: boom")

      sign_in_as(@admin)
      get db_export_path
      assert_response :success
      assert_includes response.body, "エクスポートに失敗"
    end
  end
end
