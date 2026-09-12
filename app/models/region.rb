class Region < ApplicationRecord
  has_many :landmarks, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :hiragana, presence: true,
    format: { with: /\A[ぁ-んー]+\z/, message: "はひらがなで入力してください" }
end
