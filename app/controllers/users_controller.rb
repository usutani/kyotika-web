class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[new create]

  before_action :verify_join_code, only: %i[new create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params.merge(role: :member))

    if @user.save
      start_new_session_for(@user)
      redirect_to root_path
    elsif User.active.exists?(email_address: @user.email_address.to_s.strip.downcase)
      redirect_to new_session_path, alert: "そのメールアドレスは登録済みです。ログインしてください"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def verify_join_code
      account = Account.first
      head :not_found unless account && account.join_code == params[:join_code].to_s
    end

    def user_params
      params.require(:user).permit(:name, :email_address, :password, :password_confirmation)
    end
end
