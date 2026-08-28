class Tagging < ApplicationRecord
  belongs_to :landmark
  belongs_to :tag
end
