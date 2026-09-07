# Campfire 模倣の cookie トークン認証。bot 対応は省略している。
module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :signed_in?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private
    def signed_in?
      Current.user.present?
    end

    def require_authentication
      restore_authentication || request_authentication
    end

    def restore_authentication
      if session_record = find_session_by_cookie
        if session_record.user.active?
          resume_session(session_record)
        else
          session_record.destroy!
          nil
        end
      end
    end

    def find_session_by_cookie
      if token = cookies.signed[:session_token]
        Session.find_by(token:)
      end
    end

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_path
    end

    def start_new_session_for(user)
      user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |record|
        authenticated_as(record)
      end
    end

    def resume_session(record)
      record.resume(user_agent: request.user_agent, ip_address: request.remote_ip)
      authenticated_as(record)
    end

    def authenticated_as(record)
      Current.session = record
      cookies.signed.permanent[:session_token] = { value: record.token, httponly: true, same_site: :lax }
    end

    def terminate_current_session
      Current.session&.destroy!
      reset_session
      cookies.delete(:session_token)
      Current.session = nil
    end

    def post_authenticating_url
      session.delete(:return_to_after_authenticating) || root_path
    end

    def ensure_administrator
      return if Current.user&.administrator?

      respond_to do |format|
        format.html { redirect_to root_path, alert: "管理者のみ利用できます" }
        format.json { head :forbidden }
        format.any { head :forbidden }
      end
    end
end
