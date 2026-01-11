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

  # 画像削除機能のための仮想属性
  attr_accessor :remove_image

  # --- バリデーション (基本) ---
  validates :name, presence: true, length: { maximum: 50 }
  
  # 価格: 0以上の整数、nil許可
  validates :price, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :price, length: { maximum: 10 }, if: -> { price.present? }
  
  # 色の文字数制限
  validates :color, length: { maximum: 30 }, allow_nil: true

  # --- バリデーション (拡張機能: ケア＆ヘルス管理) ---
  
  # ★修正: 洗濯頻度 0以上を許可 (0 = 洗濯管理しない / 1以上 = 管理する)
  validates :wash_frequency, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  
  # 着用回数と累積洗濯回数は 0以上の整数
  validates :wears_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :total_washes, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # 画像バリデーション
  validate :image_validation

  # --- 便利メソッド ---

  # ★「今、洗濯が必要か？」を判定するメソッド
  # (現在の着用回数 >= 設定した洗濯頻度 なら true)
  def need_wash?
    # 頻度が0（設定なし）なら、常に「洗濯不要」
    return false if wash_frequency == 0
    
    wears_count >= wash_frequency
  end

  # ★「鮮度」をパーセントで返すメソッド (100%〜0%)
  # バー表示などに使用します
  def freshness_percentage
    # 頻度が0（設定なし）なら、常に100%（減らない）
    return 100 if wash_frequency == 0
    # 未着用の場合は100%
    return 100 if wears_count.zero?
    
    # 例: 頻度5回設定で、現在2回着用 = (5-2)/5 * 100 = 60%
    remaining = wash_frequency - wears_count
    return 0 if remaining <= 0
    
    (remaining.to_f / wash_frequency * 100).to_i
  end

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
