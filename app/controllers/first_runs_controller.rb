class FirstRunsController < ApplicationController
  allow_unauthenticated_access

  before_action :prevent_repeats

  def show
    @user = User.new
  end

  def create
    user = FirstRun.create!(first_run_params)
    start_new_session_for(user)
    redirect_to root_path
  rescue ActiveRecord::RecordInvalid => error
    @user = error.record.is_a?(User) ? error.record : User.new(first_run_params)
    render :show, status: :unprocessable_entity
  end

  private
    def prevent_repeats
      redirect_to root_path if Account.exists? || User.exists?
    end

    def first_run_params
      params.require(:user).permit(:name, :email_address, :password, :password_confirmation)
    end
end
