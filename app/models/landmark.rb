class Landmark < ApplicationRecord
  belongs_to :creator, class_name: "User", optional: true, inverse_of: :created_landmarks

  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings

  validates :name, :hiragana, :question, :answer1, :answer2, :answer3, presence: true
  validates :correct, inclusion: { in: 1..3 }

  scope :owned_by, ->(user) { where(creator: user) }

  def creator_label
    if creator&.active?
      creator.name
    elsif creator
      "#{creator.name}（無効）"
    else
      "―"
    end
  end
end
