# 初回起動時に最初の管理者とアカウントを作成する (Campfire の FirstRun 相当)。
class FirstRun
  def self.needed?
    User.none?
  end

  def self.create!(user_params)
    ActiveRecord::Base.transaction do
      Account.create!(name: "京チカ")
      User.create!(user_params.merge(role: :administrator))
    end
  end
end
