class Accounts::Users::PasswordsController < ApplicationController
  before_action :ensure_administrator
  before_action :set_user

  # パスワードを忘れたメンバー向けに管理者が仮パスワードを発行する。
  def update
    if password_params[:password].blank?
      redirect_to edit_account_path, alert: "パスワードを入力してください" and return
    end

    if @user.update(password_params)
      if @user == Current.user
        @user.sessions.where.not(id: Current.session&.id).delete_all
      else
        @user.sessions.delete_all
      end
      redirect_to edit_account_path, notice: "#{@user.name} のパスワードを設定しました"
    else
      redirect_to edit_account_path, alert: @user.errors.full_messages.join("、")
    end
  end

  private
    def set_user
      @user = User.find(params[:user_id])
    end

    def password_params
      params.require(:user).permit(:password, :password_confirmation)
    end
end
