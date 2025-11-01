class Category < ApplicationRecord
  # Itemとの1対多の関連付け: 
  # このカテゴリが削除されたら、関連するアイテムも削除される 
  has_many :items, dependent: :destroy

  # バリデーション:
  # nameが空でないこと、一意であること、文字数制限
  validates :name, presence: true, uniqueness: true, length: { maximum: 30 }
end
