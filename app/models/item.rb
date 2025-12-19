class Item < ApplicationRecord
  # --- 関連付け ---
  belongs_to :user
  belongs_to :category, optional: true # category_idがnilを許容するように設定
  
  # 画像を添付できるようにする設定
  has_one_attached :image

  # アイテムは複数の着用記録を持つ (1:多)
  has_many :actual_outfits, dependent: :destroy

  # --- バリデーション ---
  validates :name, presence: true, length: { maximum: 50 }
  validates :price, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  
  # 価格が存在する場合、10桁以下であること
  validates :price, length: { maximum: 10 }, if: -> { price.present? }
  
  # 色の文字数制限
  validates :color, length: { maximum: 30 }, allow_nil: true
end
