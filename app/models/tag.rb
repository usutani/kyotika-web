class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :landmarks, through: :taggings
end
