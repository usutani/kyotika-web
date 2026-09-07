class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { render_rejection }

  before_action :ensure_user_exists, only: :new

  def new
  end

  def create
    if user = User.active.authenticate_by(email_address: params[:email_address], password: params[:password])
      start_new_session_for(user)
      redirect_to post_authenticating_url
    else
      flash.now[:alert] = "メールアドレスまたはパスワードが正しくありません"
      render :new, status: :unauthorized
    end
  end

  def destroy
    terminate_current_session
    redirect_to root_path
  end

  private
    def ensure_user_exists
      redirect_to first_run_path if FirstRun.needed?
    end

    def render_rejection
      flash.now[:alert] = "リクエストが多すぎます。しばらくしてからお試しください"
      render :new, status: :too_many_requests
    end
end
