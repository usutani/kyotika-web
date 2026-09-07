class Accounts::UsersController < ApplicationController
  before_action :ensure_administrator
  before_action :set_user, only: :update

  def update
    new_role = params.require(:user)[:role].presence_in(%w[member administrator]) || "member"

    if @user == Current.user && new_role == "member"
      redirect_to edit_account_path, alert: "自分自身をメンバーに変更できません" and return
    end

    if @user.administrator? && new_role == "member" && User.administrator.active.count <= 1
      redirect_to edit_account_path, alert: "最後の管理者はメンバーに変更できません" and return
    end

    @user.update!(role: new_role)
    redirect_to edit_account_path, notice: "#{@user.name} を#{@user.role_label}にしました"
  end

  private
    def set_user
      @user = User.find(params[:id])
    end
end
