class ActualOutfit < ApplicationRecord
  belongs_to :user

  # --- ① 現在使用している関連 (多対多) ---
  # 服 (Items) との関連
  has_many :actual_outfit_items, dependent: :destroy
  has_many :items, through: :actual_outfit_items

  # 会った人 (Contacts) との関連
  has_many :actual_outfit_contacts, dependent: :destroy
  has_many :contacts, through: :actual_outfit_contacts

  # --- ② 削除エラー回避用 ---
  has_many :outfit_items, dependent: :destroy
  has_many :outfit_contacts, dependent: :destroy

  # --- 画像 (ActiveStorage) ---
  has_one_attached :image

  # --- Enum定義 (時間帯) ---
  # DBには整数(0〜3)で保存
  enum time_slot: {
    morning: 0,       # 朝 (06:00-11:59)
    day: 1,           # 昼 (12:00-17:59)
    night: 2,         # 夕方 (18:00-23:59)
    late_night: 3     # 夜   (00:00-05:59)
  }

  # --- バリデーション ---
  validates :worn_on, presence: true
  validates :time_slot, presence: true
end
