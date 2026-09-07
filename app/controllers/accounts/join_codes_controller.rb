class Accounts::JoinCodesController < ApplicationController
  before_action :ensure_administrator
  before_action :set_account

  def create
    @account.regenerate_join_code!
    redirect_to edit_account_path, notice: "招待URLを再生成しました"
  end

  private
    def set_account
      @account = Account.first!
    end
end
