class Account < ApplicationRecord
  has_secure_token :join_code

  validates :name, presence: true
  validates :singleton_guard, uniqueness: true

  def regenerate_join_code!
    regenerate_join_code
    save!
  end
end
