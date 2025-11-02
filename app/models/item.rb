class Item < ApplicationRecord
  # Categoryモデルとの関連付け
  belongs_to :category, optional: true 

  # Userモデルとの関連付け
  belongs_to :user

  # === バリデーション ===
  # アイテム名のみを必須とする
  validates :name, presence: true
  
end
