class ActualOutfit < ApplicationRecord
  belongs_to :user

  # --- ① 現在使用している関連 (多対多) ---
  # 服 (Items) との関連
  has_many :actual_outfit_items, dependent: :destroy
  has_many :items, through: :actual_outfit_items

  # 会った人 (Contacts) との関連
  has_many :actual_outfit_contacts, dependent: :destroy
  has_many :contacts, through: :actual_outfit_contacts

  # --- ② 削除エラー回避用  ---
  has_many :outfit_items, dependent: :destroy
  has_many :outfit_contacts, dependent: :destroy

  # --- 画像 (ActiveStorage) ---
  has_one_attached :image

  # --- Enum定義 (時間帯) ---
  enum time_slot: {
    morning: 0,       # 朝 (06:00-11:59)
    day: 1,           # 昼 (12:00-17:59)
    night: 2,         # 夕方 (18:00-23:59)
    late_night: 3     # 夜   (00:00-05:59)
  }

  # --- バリデーション ---
  validates :worn_on, presence: true
  validates :time_slot, presence: true
  
  # メモの文字数制限 (長すぎるとレイアウト崩れの元)
  validates :memo, length: { maximum: 500 }, allow_nil: true

  # 画像バリデーション (動作軽量化のため他モデルと統一)
  validate :image_validation

  # --- 便利メソッド ---
  # ビューで「朝」「昼」などを表示しやすくするメソッド
  def time_slot_label
    I18n.t("enums.actual_outfit.time_slot.#{time_slot}")
  end

  private

  def image_validation
    return unless image.attached?

    # 1. ファイルサイズの制限 (5MB以下)
    if image.blob.byte_size > 5.megabytes
      errors.add(:image, "は5MB以下のファイルにしてください")
    end

    # 2. ファイル形式の制限
    if !image.content_type.in?(%w[image/jpeg image/png image/webp])
      errors.add(:image, "はJPEG, PNG, WebP形式のみ可能です")
    end
  end
end
