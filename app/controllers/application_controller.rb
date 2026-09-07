class ApplicationController < ActionController::Base
  include Authentication

  helper_method :show_session_bar?

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private
    # 公開クイズ画面では表示しない。管理・認証系画面でのみ表示する。
    def show_session_bar?
      !controller_path.start_with?("quiz/", "map_quiz/") &&
        !%w[quizzes map_quizzes].include?(controller_path)
    end
end
