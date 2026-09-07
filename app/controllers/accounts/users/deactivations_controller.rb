class Accounts::Users::DeactivationsController < ApplicationController
  before_action :ensure_administrator
  before_action :set_user

  def create
    if @user == Current.user
      redirect_to edit_account_path, alert: "自分自身を無効化できません" and return
    end

    @user.deactivate!
    redirect_to edit_account_path, notice: "#{@user.name} を無効化しました"
  end

  def destroy
    @user.reactivate!
    redirect_to edit_account_path, notice: "#{@user.name} を有効化しました"
  end

  private
    def set_user
      @user = User.find(params[:user_id])
    end
end
