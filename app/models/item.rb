class Item < ApplicationRecord
  # --- 関連付け ---
  belongs_to :user
  belongs_to :category, optional: true # category_idがnilを許容
  
  # --- 多対多のアソシエーション ---

  # 1. 中間テーブル (アイテム削除時、この紐付けデータは消す)
  has_many :actual_outfit_items, dependent: :destroy

  # 2. 着用記録 (中間テーブルを経由して取得。アイテムを消しても記録本体は消さない)
  has_many :actual_outfits, through: :actual_outfit_items

  # 画像
  has_one_attached :image

  # --- バリデーション ---
  validates :name, presence: true, length: { maximum: 50 }
  
  # 価格: 0以上の整数、nil許可
  validates :price, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  # 価格の桁数制限 (10億円未満程度)
  validates :price, length: { maximum: 10 }, if: -> { price.present? }
  
  # 色の文字数制限
  validates :color, length: { maximum: 30 }, allow_nil: true

  # 画像バリデーション
  validate :image_validation

  private

  def image_validation
    return unless image.attached?
    if image.blob.byte_size > 5.megabytes
      errors.add(:image, "は5MB以下のファイルにしてください")
    end
    if !image.content_type.in?(%w[image/jpeg image/png image/webp])
      errors.add(:image, "はJPEG, PNG, WebP形式のみ可能です")
    end
  end
end
