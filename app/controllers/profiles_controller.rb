class ProfilesController < ApplicationController
  def show
    @user = Current.user
  end

  def update
    @user = Current.user

    if password_change_requested? && !@user.authenticate(profile_params[:current_password])
      @user.errors.add(:current_password, "が正しくありません")
      render :show, status: :unprocessable_entity and return
    end

    if @user.update(profile_params.except(:current_password))
      redirect_to profile_path, notice: "更新しました"
    else
      render :show, status: :unprocessable_entity
    end
  end

  private
    def profile_params
      params.require(:user).permit(:name, :current_password, :password, :password_confirmation)
    end

    def password_change_requested?
      profile_params[:password].present? || profile_params[:password_confirmation].present?
    end
end
