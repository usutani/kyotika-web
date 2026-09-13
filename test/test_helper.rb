ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    def create_user!(name:, email_address:, role: :member, password: "password123")
      User.create!(name:, email_address:, role:, password:, password_confirmation: password)
    end

    def create_landmark!(name:, hiragana: "てすと", creator: nil, region: nil, **options)
      region ||= Region.find_by(name: "京都") || regions(:kyoto)
      Landmark.create!(name:, hiragana:, question: "これは何ですか？",
        answer1: "答1", answer2: "答2", answer3: "答3", correct: 1, creator:, region:, **options)
    end

    # SeedsDumpJob.export_dir をテスト専用ディレクトリに差し替える。
    # 並列実行ワーカー間で tmp/exports を共有しないための隔離用。
    def with_export_dir
      Dir.mktmpdir do |dir|
        export_dir = Pathname.new(dir)
        original = SeedsDumpJob.method(:export_dir)
        SeedsDumpJob.define_singleton_method(:export_dir) { export_dir }
        begin
          yield export_dir
        ensure
          SeedsDumpJob.define_singleton_method(:export_dir, original)
        end
      end
    end
  end

  class ActionDispatch::IntegrationTest
    def sign_in_as(user, password: "password123")
      post session_path, params: { email_address: user.email_address, password: }
    end
  end
end
