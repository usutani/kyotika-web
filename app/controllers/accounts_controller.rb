class AccountsController < ApplicationController
  before_action :ensure_administrator
  before_action :set_account
  before_action :set_user_lists, only: %i[edit update]

  def edit
    @join_url = join_url(join_code: @account.join_code)
  end

  def update
    if @account.update(account_params)
      redirect_to edit_account_path, notice: "更新しました"
    else
      @join_url = join_url(join_code: @account.join_code)
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_account
      @account = Account.first!
    end

    def set_user_lists
      users = User.ordered.includes(:created_landmarks)
      @administrators, @members = users.partition(&:administrator?)
      @deactivated = @members.select(&:deactivated?)
      @members -= @deactivated
      @orphan_landmark_count = Landmark.where.missing(:creator).count
    end

    def account_params
      params.require(:account).permit(:name)
    end
end
