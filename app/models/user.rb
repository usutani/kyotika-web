class User < ApplicationRecord
  has_secure_password

  has_many :sessions, dependent: :destroy
  has_many :created_landmarks, class_name: "Landmark", foreign_key: "creator_id",
    dependent: :nullify, inverse_of: :creator

  enum :role, { member: 0, administrator: 1 }
  enum :status, { active: 0, deactivated: 1 }

  normalizes :email_address, with: ->(value) { value.strip.downcase }

  validates :name, presence: true
  validates :email_address, presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, allow_nil: true

  scope :ordered, -> { order("LOWER(name)") }

  def deactivate!
    transaction do
      sessions.delete_all
      update!(status: :deactivated)
    end
  end

  def reactivate!
    update!(status: :active)
  end

  def role_label
    administrator? ? "管理者" : "メンバー"
  end

  def status_label
    active? ? "有効" : "無効"
  end
end
