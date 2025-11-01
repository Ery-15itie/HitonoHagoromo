class Item < ApplicationRecord
  # 関連付け:
  # アイテムは必ずユーザーとカテゴリに属する
  belongs_to :user
  belongs_to :category 

  # バリデーション:
  # name: 必須、文字数制限
  validates :name, presence: true, length: { maximum: 50 }
  # category_id: 必須 
  validates :category_id, presence: true 
  # description: 文字数制限
  validates :description, length: { maximum: 500 }
  # price: 0以上の整数のみを許可し、入力は任意 (nilを許可)
  validates :price, numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_nil: true }
  # color: 文字数制限 (入力は任意)
  validates :color, length: { maximum: 20, allow_nil: true }
end
